class SectionDecorator < Draper::Decorator
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
		return "danger"
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

	def instructors
		return nil if !object.instructors
		h.raw(object.instructors.split(";").map do |i|
			helpers.inline_form(format_name(i), "instructor:#{i.split.first.downcase}")
		end.join(", "))
	end
end