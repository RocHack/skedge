class Course < ActiveRecord::Base
	belongs_to :department

	def no_cap?
		cap == 0
	end

	def enroll_percent
		enroll*100.0/cap
	end

	def time_tba?
		days == "TBA"
	end
end
