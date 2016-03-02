module DataFormatter
  module Course
    # we use a whitelist for this bc there are some course series with A, B, C, etc
    def self.courses_with_abc_section
      ["PHY 113", "PHY 114"]
    end

    def self.clusters(clusters)
      clusters.split(",").map do |c|
        c.strip!
        "<a href='http://rochack.org/clustergraph/#cluster:#{c.downcase}'>#{c}</a>"
      end.join(", ")
    end

    def self.restrictions(restrictions)
      return nil if restrictions.nil? || !restrictions.present?
      restrictions.gsub(/\[.*\]\s*/,"") #remove [A] stuff
    end

    def self.comments(dept, num, comments)
      return nil if comments.nil? || !comments.present?
      
      comments.gsub!(/(\d+)WHEN/, '\1 WHEN')
      comments.gsub!("LABLECTURE", "LAB LECTURE")
      comments.gsub!("THELAB", "THE LAB")
      comments.gsub!("ALSOREGISTER", "ALSO REGISTER")
      comments.gsub!("LECTUREWHEN", "LECTURE WHEN")
      comments.gsub!("WHENREGISTERING", "WHEN REGISTERING")
      comments.gsub!("REGISTERINGFOR", "REGISTERING FOR")
      comments.gsub!("MAINSECTION", "MAIN SECTION")
      comments.gsub!("THEMAIN", "THE MAIN")
      comments.gsub!("FORTHE", "FOR THE")
      comments.gsub!("'B'LAB", "'B' LAB")
      comments.gsub!("'A'LAB", "'A' LAB")
      comments.gsub!("'A'WORKSHOP", "'A' WORKSHOP")
      comments.gsub!("'B'WORKSHOP", "'B' WORKSHOP")
      comments.gsub!("\"WHEN", "\" WHEN")
      comments
    end

    def self.title(name, cn)
      little = %w(a at an and of or the to the in but as is for with vs. into by on from)
      exact = %w(UG HIV AIDS DSP GPU HCI VLSI VLS CMOS EAPP ESOL ABC US USA NY MRI FMRI BME CHM ECE LIN CSC LGBTQ CAD ASL iPhone iReligion NMR)
      seps = %w(: ’ ')
      prev = nil
      split = name.split(/\s*(?<=:| )\s*/) #use lookbehind as to not eat up the separator
      name = split.map.with_index do |s, i|
        prev = s.gsub(/(\p{Word}|’|')+/) do |w|
          if exact.include?(w)
            w
          elsif w =~ /^(I+|\d+)([A-D]|V|)(:|\b)$/ || w =~ /^M?T?W?R?F?$/
            w
          elsif w =~ /^[A-D]$/ && i == split.size-1 #last one
            w
          elsif little.include?(w.downcase) && prev && !prev.match(/(:|-|–)$/)
            w.downcase
          else
            w.to_s.mb_chars.capitalize.to_s #in case there are multibyte chars like É
          end
        end
      end.join(" ")
      name.gsub!(/-?\s*[A-C]$/) do |x|
        nil
      end if courses_with_abc_section.include? cn
      name.strip
    end

    def self.encode(txt)
      return nil if txt.nil? || !txt.present?
      #PH 236 has a weird encoding in its description, sanitizing everything to be sure
      txt.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => '')
    end

    def self.term(term)
      {
        "Fall"    => ::Course::Term::Fall,
        "Spring"  => ::Course::Term::Spring,
        "Winter"  => ::Course::Term::Winter,
        "Summer"  => ::Course::Term::Summer,
      }[term]
    end

    def self.credits(credits)
      return nil if credits.nil? || !credits.present?
      if credits =~ /[1-9]\.[1-9]|0\.[1-9]/
        credits.strip
      else
        credits.to_i.to_s
      end
    end
  end

  module Section
    def self.status(status)
      {
        "Open"      => ::Section::Status::Open,
        "Closed"    => ::Section::Status::Closed,
        "Cancelled" => ::Section::Status::Cancelled
      }[status]
    end

    def self.type(credits, title)
      #dumb csc 171 exception
      if title.match(/- wkshp/i)
        return ::Section::Type::Workshop
      end

      if (!credits.present? || credits =~ /\d\.\d/)
        return ::Section::Type::Course
      end

      {
        "LAB" => ::Section::Type::Lab,
        "REC" => ::Section::Type::Recitation,
        "L/L" => ::Section::Type::LabLecture,
        "WRK" => ::Section::Type::Workshop,
      }[credits] || ::Section::Type::Course
    end

    def self.instructors(instructors)
      return nil if instructors.nil?
      instructors.split(';').map do |name|
        name.strip!
        split = name.split(/(?<=-|'| )/)
        if name =~ /^MC/
          split = name.split(/(?<=^MC|-|'| )/)
        elsif name =~ /^ST[^AEIOU]/
          split = name.split(/(?<=^ST|-|'| )/)
          split[0] << " "
        end
        split.map do |x|
          x.downcase!
          x[0] = x[0].upcase
          x
        end.join('')
      end.join('; ')
    end
  end
end