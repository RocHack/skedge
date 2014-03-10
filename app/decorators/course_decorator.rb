class CourseDecorator < Draper::Decorator
	delegate_all

	def term
		case object.term
		when Course::Term::Fall
			"Fall"
		when Course::Term::Spring
			"Spring"
		end
	end

	def dept_and_cnum
		"#{object.dept} #{object.number}"
	end
end
