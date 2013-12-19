class Section < ActiveRecord::Base
	module Status
		Open = 0
		Closed = 1
		Cancelled = 2

		Statuses = {"Open" => Open, "Closed" => Closed, "Cancelled" => Cancelled}
	end

	belongs_to :course
	validates :crn, presence: true, uniqueness: true

	def hour(start_or_end)
		send(:"#{start_or_end}_time").to_s.rjust(4,"0")[0..1].to_i #first two, accounting for 3-digits, ie, "940"
	end

	def minutes(start_or_end)
		send(:"#{start_or_end}_time").to_s[-2..-1].to_i #last 2
	end

	def time_in_hours(start_or_end)
		hour(start_or_end)+minutes(start_or_end)/60.0
	end

	def duration
		time_in_hours(:end) - time_in_hours(:start)
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
