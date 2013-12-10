class Course < ActiveRecord::Base
	validates :crn, uniqueness: true
	belongs_to :department

	def no_cap?
		cap == 0 || cap == nil
	end

	def enroll_percent
		enroll*100.0/cap
	end

	def time_tba?
		days == "TBA"
	end
end
