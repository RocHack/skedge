class Course
	include Mongoid::Document
	field :title, type: String
	field :number, type: String
	field :description, type: String
	field :credits, type: Integer
	field :restrictions, type: String
	field :instructors, type: Array
	field :dept, type: String
	field :clusters, type: Array
	field :prereqs, type: String
	field :cross, type: String
	field :comments, type: String

	def old?
		!(term == Course::Term::Spring && year == 2014)
	end

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
		(!desc || desc.empty?) && sections.inject(true) { |x, s| x && s.time_tba? }
	end
end
