class CourseDecorator < Draper::Decorator
	delegate_all

	def term
		case object.term
		when Section::Term::Fall
			"Fall"
		when Section::Term::Spring
			"Spring"
		end
	end

	def term_and_year
		"#{term} #{year}"
	end

	def dept_and_cnum
		"#{object.dept} #{object.number}"
	end
end
