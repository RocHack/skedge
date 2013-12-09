class Course < ActiveRecord::Base
	belongs_to :department

	def enroll_percent
		return 100 if cap == 0
		enroll*100.0/cap
	end

	def bar_style
		return "success" if enroll_percent < 75 || cap == 0
		return "warning" if enroll_percent < 90
		"danger"
	end
end
