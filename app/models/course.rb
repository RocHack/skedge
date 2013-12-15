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
	validates :name, presence: true, uniqueness: {scope: [:term, :year]}
	
	belongs_to :department

	belongs_to :main_course, class_name:"Course"
	has_many :subcourses, foreign_key:"main_course_id", class_name:"Course"
	has_many :sections, order: [:status, :days, :start_time]

	has_one :sister_course, class_name:"Course", foreign_key:"sister_course_id"

	def filter_subcourses(type)
		Section.joins{course}.where do
			(course.main_course_id == my{id}) &
			(course.course_type == type)
		end.order([:days,:start_time])
	end

	def labs
		filter_subcourses(Course::Type::Lab)
	end

	def recitations
		filter_subcourses(Course::Type::Recitation)
	end

	def lab_lectures
		filter_subcourses(Course::Type::LabLecture)
	end

	def workshops
		filter_subcourses(Course::Type::Workshop)
	end

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
end
