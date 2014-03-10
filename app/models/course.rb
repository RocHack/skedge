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
	embeds_many :sections

	def select_sections(type)
		sections.select { |s| s.section_type == type }
	end

	def lectures; select_sections(Section::Type::Course); end
	def labs; select_sections(Section::Type::Lab); end
	def workshops; select_sections(Section::Type::Workshop); end
	def lab_lectures; select_sections(Section::Type::LabLecture); end
	def recitations; select_sections(Section::Type::Recitation); end

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
end
