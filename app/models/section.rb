class Section < ActiveRecord::Base
	module Status
		Open = 0
		Closed = 1
		Cancelled = 2

		Statuses = {"Open" => Open, "Closed" => Closed, "Cancelled" => Cancelled}
	end

	belongs_to :course

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
		course.term == Course::Term::Spring && status == Status::Open
	end

	def enroll_percent
		enroll*100.0/cap
	end

	def time_tba?
		days == "TBA"
	end

	def multiple_instructors?
		instructors[";"]
	end
end
