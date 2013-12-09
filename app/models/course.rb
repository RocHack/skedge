class Course < ActiveRecord::Base
	belongs_to :department

	def enroll_percent
		enroll*100.0/cap
	end

	def bar_style
		return "success" if enroll_percent < 75
		return "warning" if enroll_percent < 90
		"danger"
	end
end
