class Course < ActiveRecord::Base
	module Type
		Course = 0
		Lab = 1
	    Recitation = 2
	    LabLecture = 3
	    Workshop = 4
	    
	    Types = {"LAB" => Lab, "REC" => Recitation, "L/L" => LabLecture, "WRK" => Workshop}
	end

	module Term
		Fall = 0
		Spring = 1

		Terms = {"Fall" => Fall, "Spring" => Spring}
	end

	validates :num, presence: true
	validates :name, presence: true, uniqueness: {scope: [:department_id, :num, :term, :year]}
	
	belongs_to :department
	belongs_to :main_course, class_name:"Course"

	has_many :bookmarks

	has_many :sections, -> { order([:status, :days, :start_time]) }
	has_many :fall_sections, -> { where(term == Course::Term::Fall).order([:status, :days, :start_time]) }
	has_many :spring_sections, -> { where(term == Course::Term::Spring).order([:status, :days, :start_time]) }

	def self.scope(type)
		lambda { where(course_type:type).order([:days,:start_time]) }
	end

	has_many :labs, scope(Course::Type::Lab), class_name:"Section", foreign_key:"main_course_id"
	has_many :recitations, scope(Course::Type::Recitation), class_name:"Section", foreign_key:"main_course_id"
	has_many :workshops, scope(Course::Type::Workshop), class_name:"Section", foreign_key:"main_course_id"
	has_many :lab_lectures, scope(Course::Type::LabLecture), class_name:"Section", foreign_key:"main_course_id"

	has_one :sister_course, class_name:"Course", foreign_key:"sister_course_id"

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
