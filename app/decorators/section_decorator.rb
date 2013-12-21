class SectionDecorator < Draper::Decorator
	delegate_all

	DaysOfWeek = {"M" => "Mon", "T" => "Tues", "W" => "Wed", "R" => "Thurs", "F" => "Fri", "S" => "Sat", "U" => "Sun"}

	def format_time(time, ampm=true)
		hour = object.hour(time)
		mins = object.minutes(time)
		am = hour < 12
		if hour > 12
			hour = "#{hour - 12}"
		end
		"#{hour}:#{mins.to_s.rjust(2,"0")}#{ampm ? (am ? "am" : "pm") : ""}"
	end

	def time(ampm=true)
		s = format_time(:start,ampm)
		e = format_time(:end,ampm)
		"#{s}-#{e}"
	end

	def time_and_day
		# days is like "MWF". split into chars, map each one to the longer version, join with /, so Mon/Wed/Fri
		d = object.days.split("").map {|d| DaysOfWeek[d]}.join("/")
		"#{d} #{time}"
	end

	def popover_content
		"<p><strong>Instructors:</strong> #{instructor_list.join(", ")}</p><p class=\"popover-desc\">#{course.desc}</p>"
	end

	def popover_title
		h.inline_form(course.decorate.dept_and_cnum).strip+"<span class=\"popover-credits\">#{course.credits} credits</span>"
	end

	def time_and_place
		if object.time_tba?
			"TBA"
		else
			time_and_day + (!object.building.empty? ? ", #{object.building} #{object.room}" : "")
		end
	end

	def status
		case object.status
		when Section::Status::Open
			"Open"
		when Section::Status::Closed
			"Closed"
		when Section::Status::Cancelled
			"Cancelled"
		end
	end

	def button_text(name)
		if object.can_enroll?
        	"Add #{name}"
      	elsif object.course.old?
      		course.decorate.term_and_year
        else
        	status
        end
        #"Conflict – CSC 172"
	end

	def enroll_bar_style
		return "info" if object.no_cap?
		return "success" if object.enroll_percent < 75
		return "warning" if object.enroll_percent < 90
		return "danger" if object.enroll_percent < 100
		return "closed"
	end

	def enroll_bar_precentage
		return 100 if object.no_cap?
		object.enroll_percent
	end

	def enroll_ratio
		"#{object.enroll}/#{object.no_cap? ? "∞" : object.cap}"
	end

	def add_button_class
		if object.course.course_type == Course::Type::Course
			object.can_enroll? ? "btn-primary" : "disabled" #:"btn-danger"
		else
			object.can_enroll? ? "btn-primary" : "disabled full"
		end
	end

	def add_button_tooltip
		# "Replace CSC 172?"
		object.course.requires_code? ? "Instructor's permission is required." : ""
	end

	def format_name(name)
		name.downcase.gsub(/mc (.*)/, 'mc\1').gsub(/(^|\s+|'|-)(mc)?[A-Za-z]/) do |w|
			w.upcase!
			if w.start_with? "MC"
				w[1] = "c"
			end
			w
		end
	end

	def instructor_list
		return [] if !object.instructors
		object.instructors.split(";").map do |i|
			format_name(i)
		end
	end
end