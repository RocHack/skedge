class Course
	include Mongoid::Document
	field :title, type: String
	field :number, type: String
	field :description, type: String
	field :credits, type: Integer
	field :restrictions, type: String
	field :dept, type: String
	field :clusters, type: Array
	field :prereqs, type: String
	field :cross, type: String
	field :comments, type: String

	field :term, type: Integer
	field :year, type: Integer
	field :latest, type: Boolean
	field :min_enroll, type: Integer
	field :min_start, type: Integer
	field :max_start, type: Integer

	embeds_many :sections
	embeds_many :labs,         class_name: 'Section', inverse_of: :course
	embeds_many :workshops,    class_name: 'Section', inverse_of: :course
	embeds_many :lab_lectures, class_name: 'Section', inverse_of: :course
	embeds_many :recitations,  class_name: 'Section', inverse_of: :course

	def has_prereqs?
		prereqs && prereqs.downcase != "none"
	end

	def requires_code?
		(restrictions && restrictions["[A]"]) || (prereqs && prereqs =~ /Permission of instructor required/)
	end

	def cancelled?
		sections.inject(true) { |x, s| x && s.status == Section::Status::Cancelled }
	end

	def research?
		(!description || description.empty?) && sections.inject(true) { |x, s| x && s.time_tba? }
	end

	def relation(type)
		case type
	    when Section::Type::Course; sections
	    when Section::Type::Lab; labs
	    when Section::Type::Recitation; recitations
	    when Section::Type::LabLecture; lab_lectures
	    when Section::Type::Workshop; workshops
	    end
	end

	class Formatter
		def self.linkify(short, txt) 
		  #matches any strings that are like "ABC 123", and replaces them with links
		  last_dept = short #default to course's dept (ie if just "291")
		  regex = /([A-Za-z]{0,3})\s*(\d{3}[A-Za-z]*)/
		  str = txt.gsub(regex) do |w|
		    match = w.match regex
		    dept = match[1].strip
		    num = match[2].strip
		    
		    not_link = ""
		    if dept.empty? || dept == "or" || dept == "of" || dept == "and" || dept == "one" || dept == "two" || dept == "three"
		      not_link = dept
		      link = last_dept+"+"+num
		    else
		      last_dept = dept
		      link = w.strip.gsub(" ","+")
		    end

		    not_link + "<a href='/?q=#{link}'>#{w}</a>"
		  end
		  str
		end

	  def self.format_clusters(clusters)
	    clusters.split(",").map do |c|
	      c.strip!
	      "<a href='http://rochack.org/clustergraph/#cluster:#{c.downcase}'>#{c}</a>"
	    end.join(", ")
	  end

	  def self.format_restrictions(restrictions)
	    restrictions.gsub(/\[.*\]\s*/,"") #remove [A] stuff
	  end

	  def self.format_name(name)
	    little = %w(and of or the to the in but as is for with)
	    exact = %(HIV AIDS GPU HCI VLSI VLS CMOS EAPP ABC NY MRI FMRI BME CHM ECE LIN CSC BIO LGBTQ iPhone)
	    prev = nil
	    name.gsub(/(\w|\.|')*/) do |w|
	      w2 = if little.include?(w.downcase) && prev && !prev.match(/:|-|–$/)
	        w.downcase
	      elsif exact.include?(w)
	        w
	      elsif w =~ /^(I*|\d)([A-D]|V|)((:|\b)?)$/ || w =~ /^([A-Z]\.)*$/ || w =~ /^M?T?W?R?F?$/
	        w
	      else
	        w.capitalize
	      end
	      prev = w2 if !w2.strip.empty?
	      w2
	    end
	  end

	  def self.encode(txt)
	    #PH 236 has a weird encoding in its description, sanitizing everything to be sure
	    txt.encode("ISO-8859-1", :invalid => :replace, :undef => :replace, :replace => '')
	  end
	end
end
