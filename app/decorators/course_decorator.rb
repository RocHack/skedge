class CourseDecorator < Draper::Decorator
	delegate_all

	def term
		["Fall", "Spring", "Summer", "Winter"][object.term]
	end

	def term_and_year
		"#{term} #{year}"
	end

	def dept_and_cnum
		"#{object.dept} #{object.number}"
	end
end
