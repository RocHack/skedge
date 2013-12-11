class Course < ActiveRecord::Base
	validates :crn, uniqueness: true
	belongs_to :department

	belongs_to :main_course, class_name:"Course"
	has_many :subcourses, foreign_key:"main_course_id", class_name:"Course"

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
		term == "Spring" && status == Status::Open
	end

	def old?
		term != "Spring" && year != 2014
	end

	def status_string
		return "Open" if status == Status::Open
		return "Closed" if status == Status::Closed
		return "Cancelled" if status == Status::Cancelled
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

	def formatted_name
		little = %w(and of or the to the in but)
		big = %(HIV AIDS GPU HCI)
		prev = nil
		name.gsub(/(\w|\.|-|'|:)*/) do |w|
			w2 = if little.include?(w.downcase) && prev && !prev.match(/:|-|–$/)
				w.downcase
			elsif big.include?(w.upcase)
				w.upcase
			elsif w =~ /^I*([A-D]|V|)$/ || w =~ /^([A-Z]\.)*$/
				w
			else
				w.capitalize
			end
			prev = w2 if !w2.strip.empty?
			w2
		end
	end
end
