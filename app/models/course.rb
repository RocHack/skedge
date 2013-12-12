class Course < ActiveRecord::Base
	module Type
		Course = 0
		Lab = 1
	    Recitation = 2
	    LabLecture = 3
	    Workshop = 4
	    
	    Types = {"LAB" => Lab, "REC" => Recitation, "L/L" => LabLecture, "WRK" => Workshop}
	end

	module Status
		Open = 0
		Closed = 1
		Cancelled = 2

		Statuses = {"Open" => Open, "Closed" => Closed, "Cancelled" => Cancelled}
	end

	module Term
		Fall = 0
		Spring = 1

		Terms = {"Fall" => Fall, "Spring" => Spring}
	end

	validates :crn, presence: true, uniqueness: true
	validates :num, presence: true
	validates :name, presence: true
	
	belongs_to :department

	belongs_to :main_course, class_name:"Course"
	has_many :subcourses, foreign_key:"main_course_id", class_name:"Course"

	has_one :sister_course, class_name:"Course", foreign_key:"sister_course_id"

	def filter_subcourses(type)
		subcourses.select do |course|
			course.course_type == type
		end
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

	def cap
		tot_cap || sec_cap
	end

	def enroll
		tot_enroll || sec_enroll
	end

	def no_cap?
		cap == 0 || cap == nil
	end

	def can_enroll?
		term == Course::Term::Spring && status == Status::Open
	end

	def old?
		!(term == Course::Term::Spring && year == 2014)
	end

	def enroll_percent
		enroll*100.0/cap
	end

	def time_tba?
		days == "TBA"
	end

	def has_prereqs?
		prereqs && prereqs.downcase != "none"
	end

	def requires_code?
		(restrictions && restrictions["[A]"]) || (prereqs && prereqs =~ /Permission of instructor required/)
	end
end
