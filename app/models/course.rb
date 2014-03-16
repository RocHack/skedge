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
end
