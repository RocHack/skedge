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

	def term_and_year
		"#{term} #{object.year}"
	end

	def dept_and_cnum
		"#{object.short} #{object.num}"
	end
end
