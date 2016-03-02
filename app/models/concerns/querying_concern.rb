module QueryingConcern
  extend ActiveSupport::Concern
  
  TitleMatchPrefix = "(%( |-|:|,)+|)"
  TitleMatchSuffix = "%"

  included do
    def self.sanitize_similar_to_match(text)
      text.gsub(/[\|\*\+\?\{\}\(\)\[\]'"_\%]/) do |x|
        "\\#{x}"
      end
    end

    def self.title_match(text)
      TitleMatchPrefix+sanitize_similar_to_match(text).gsub(" ", " (% )*")+TitleMatchSuffix
    end

    def self.pg_where(attrs)
      query = where({})
      attrs.each do |key, val|
        if val.is_a? String and val.include? "%"
          query = query.where("lower(#{key}) SIMILAR TO ?", val.downcase)
        elsif val.is_a? Hash 
          if (val[:<=] or val[:>=] or val[:>] or val[:<])
            val.each do |op, cond|
              query = query.where("#{key} #{op} ?", cond)
            end
          else
            val.each do |second_key, cond|
              if cond.is_a? String and cond.include? "%"
                query = query.where("#{key}.#{second_key} ILIKE ?", cond)
              else
                query = query.where("#{key}.#{second_key} = ?", cond)
              end
            end
          end
        else 
          query = query.where(key => val)
        end
      end
      query
    end

    def self.text_to_query(text)
      text = text.clone
      
      if not defined? Struct::Query
        Struct.new('Query', :attrs, :joins, :orders, :limit, :error, :new)
      end

      query = Struct::Query.new
      query.attrs = attrs = Hash.new
      query.joins = joins = []
      query.orders = orders = []
      query.new = false

      if !text || text.strip.empty?
        query.error = "empty"
        return query
      end

      ##
      # Quotes (description search)
      #
      text.gsub!(/"\s*(.*?)\s*"/) do |x|
        attrs[:description] = "%#{sanitize_similar_to_match($1)}%"
        nil
      end

      ##
      # "New" course search
      #
      text.gsub!(/\bnew\b/) do |x|
        query.new = true
        nil
      end

      ##
      # Credits
      #
      block = lambda do |x|
        if $1.present?
          if $3.present?
            attrs[:credits] ||= {}
            attrs[:credits][:>=] = $1
            attrs[:credits][:<=] = $3
          else
            attrs[:credits] = $1
          end
          nil
        else
          x.to_s
        end
      end
      text.gsub!(/\b(\d+\.?\d?)\s*(-\s*(\d+\.?\d?))?\s*credits?\b/i, &block)
      text.gsub!(/\bcredits?:?\s*(\d+\.?\d?)\s*(-\s*(\d+\.?\d?))?\b/i, &block)

      ##
      # Dept
      #
      text.gsub!(/\b([a-zA-Z]{2,4})(\d{1,3}[a-zA-Z]*)?\b/) do |x|
        dep = Department.find_by_short($1.to_s.strip)
        if dep && !attrs[:department_id]
          attrs[:department_id] = dep.id
          $2
        else
          x.to_s
        end
      end

      ##
      # Cross listed
      #
      text.gsub!(/\bx ([a-zA-Z]{2,3})\b/i) do |x|
        if Department.find_by_short($1.strip)
          attrs[:crosslisted] = "%#{$1}%"
          nil
        else
          x.to_s
        end
      end

      ##
      # CRN
      #
      text.gsub!(/\b\d{5}\b/) do |x|
        attrs[:sections] ||= {}
        attrs[:sections][:crn] = x.to_s.to_i
        joins << :sections
        nil
      end

      ##
      # Year
      #
      text.gsub!(/\b201\d\b/) do |x|
        attrs[:year] = x.to_s.to_i
        nil
      end

      ##
      # Numbers (w/wo w's)
      #
      text.gsub!(/\b(\d{1,3})([A-Za-z]*)\b/) do |x|
        attrs[:number] = $1+"%"
        attrs[:number] += $2.split("").map { |x| x.upcase+"%" }.join
        nil
      end

      ##
      # Instructors
      #
      text.gsub!(/\b((courses?\s*)?taught\s*by|professor|prof|instructed|instructor)\s*(\w+)\b/) do |x|
        attrs[:sections] ||= {}
        attrs[:sections][:instructors] = "%#{$3.upcase}%"
        joins << :sections
        nil
      end

      ##
      # Early/late
      #
      2.times do
        %w[early late fall spring summer winter small].each do |term|
          text.gsub!(/^\s*#{term}\b|\b#{term}\s*$/) do |x|
            if term == "early"
              query.orders << "min_start ASC nulls last"
            elsif term == "late"
              query.orders << "max_start desc nulls last"
            elsif term == "small"
              query.orders << "min_enroll ASC nulls last"
            else
              attrs[:term] ||= []
              attrs[:term] << Course::FormatTerm.map(&:downcase).index(term)
            end
            nil
          end
        end
      end
      
      ##
      # Random
      #
      text.gsub!(/\brandom\b/i) do |x|
        query.orders = ["RANDOM()"]
        query.limit = 1
        nil
      end

      if attrs[:term].try(:size) == 1
        attrs[:term] = attrs[:term].first
      end

      ##
      # Title
      #
      w = text.gsub!(/\bw\b/) do |x|
        if attrs[:number] && attrs[:number].index("W")
          x.to_s
        else
          attrs[:number] ||= '%'
          attrs[:number] += 'W%'
          nil
        end
      end

      text.strip!

      if !text.empty?
        attrs[:title] = title_match(text)
      end

      # Check valid search
      if query.orders != ["RANDOM()"] &&
        ((attrs.size == 0) or
         (attrs.size == 1 and
           ((attrs[:term] or attrs[:year] or attrs[:credits]) or
           (attrs[:number] and attrs[:number].length <= 3))) or #plus the '%'
         (attrs.size == 2 and
           (attrs[:year] and attrs[:term])))
         query.error = "scope too big"
      elsif ((attrs.size == 1 or (attrs.size == 2 && attrs[:year])) and
          text.present? and
          text.length < 3)

        query.error = "please enter at least 3 characters of a title"
      elsif (query.orders &&
             query.orders.find {|x| x["min_start"] } &&
             query.orders.find {|x| x["max_start"] })

        query.error = "how can one be both early and late?"
      elsif (query.new and attrs[:year])
        query.error = "cannot specify 'new' and a year - the current and previous year will always be compared"  
      end

      attrs[:credits] ||= { :> => '0' }

      query
    end
  end
end