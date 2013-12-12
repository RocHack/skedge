class CourseDecorator < Draper::Decorator
	delegate_all

	DaysOfWeek = {"M" => "Mon", "T" => "Tues", "W" => "Wed", "R" => "Thurs", "F" => "Fri", "S" => "Sat", "U" => "Sun"}

	def format_time(time)
		if time.size == 3 #940
			hour = time[0].to_i #9
			mins = time[1..2] #40
		else #1050
			hour = time[0..1].to_i #10
			mins = time[2..3] #50
		end
		am = hour < 12
		if hour > 12
			hour = "#{hour - 12}"
		end
		"#{hour}:#{mins}#{am ? "am" : "pm"}"
	end

	def time_and_day
		# days is like "MWF". split into chars, map each one to the longer version, join with /, so Mon/Wed/Fri
		d = object.days.split("").map {|d| DaysOfWeek[d]}.join("/")
		s = format_time(object.start_time.to_s)
		e = format_time(object.end_time.to_s)
		"#{d} #{s}-#{e}"
	end

	def time_and_place
		if object.time_tba?
			"TBA"
		else
			"#{time_and_day}, #{object.building} #{object.room}"
		end
	end

	def term
		case object.term
		when Course::Term::Fall
			"Fall"
		when Course::Term::Spring
			"Spring"
		end
	end

	def status
		case object.status
		when Course::Status::Open
			"Open"
		when Course::Status::Closed
			"Closed"
		when Course::Status::Cancelled
			"Cancelled"
		end
	end

	def name
		little = %w(and of or the to the in but)
		big = %(HIV AIDS GPU HCI)
		prev = nil
		object.name.gsub(/(\w|\.|'|:)*/) do |w|
			w2 = if little.include?(w.downcase) && prev && !prev.match(/:|-|–$/)
				w.downcase
			elsif big.include?(w.upcase)
				w.upcase
			elsif w =~ /^I*([A-D]|V|)$/ || w =~ /^([A-Z]\.)*$/ || w =~ /^(M|)(T|)(W|)(R|)(F|)$/
				w
			else
				w.capitalize
			end
			prev = w2 if !w2.strip.empty?
			w2
		end
	end

	def linkify(attribute)
		if attribute == :instructors
			return h.raw(instructors.split("; ").map do |i|
							helpers.inline_form(i, "instructor:#{i.split.first.downcase}")
						end.join("; "))
		end

		#matches any strings that are like "ABC 123", and replaces them with inline_form
		last_dept = object.department.short #default to course's dept (ie if just "291")
		regex = /(\A|\s)([A-Za-z]*)\s*(\d+[A-Za-z]*)/
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

	def button_text(name)
		if object.can_enroll?
        	"Add #{name}"
      	elsif object.old?
      		term_and_year
        else
        	status
        end
	end

	def enroll_bar_style
		return "info" if object.no_cap?
		return "success" if object.enroll_percent < 75
		return "warning" if object.enroll_percent < 90
		return "danger"
	end

	def enroll_bar_precentage
		return 100 if object.no_cap?
		object.enroll_percent
	end

	def restrictions
		return nil if !object.restrictions
		object.restrictions.gsub(/\[.*\]\s*/,"") #remove [A] stuff
	end

	def term_and_year
		"#{term} #{object.year}"
	end

	def dept_and_cnum
		"#{object.department.short} #{object.num}"
	end

	def enroll_ratio
		"#{object.enroll}/#{object.no_cap? ? "∞" : object.cap}"
	end

	def add_button_class
		if object.course_type == Course::Type::Course
			object.can_enroll? ? "btn-success" : "disabled"
		else
			object.can_enroll? ? "btn-primary" : "disabled full"
		end
	end

	def add_button_tooltip
		object.requires_code? ? "Instructor's permission is required." : ""
	end
end
