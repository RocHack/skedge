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

	def linkify(attribute) 
        #matches any strings that are like "ABC 123", and replaces them with inline_form
        last_dept = object.short #default to course's dept (ie if just "291")
	    regex = /(\A|\s)([A-Za-z]{0,3})\s*(\d{3}[A-Za-z]*)/
	    str = object.send(attribute).gsub(regex) do |w|
            match = w.match regex
            link = w
            not_link = ""
            dept = match[2].strip
            num = match[3].strip
            if dept.empty? || dept == "or" || dept == "of" || dept == "and"
                not_link = " "+dept
                w = num
                link = last_dept+" "+num
            else
                last_dept = dept
            end
            not_link + " " + helpers.inline_form(w,link).strip #strip off some whitespace that seems to come w the form
        end
	    h.raw str
    end

	def restrictions
		return nil if !object.restrictions
		object.restrictions.gsub(/\[.*\]\s*/,"") #remove [A] stuff
	end

	def term_and_year
		"#{term} #{object.year}"
	end

	def dept_and_cnum
		"#{object.short} #{object.num}"
	end
end
