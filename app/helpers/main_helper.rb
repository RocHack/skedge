module MainHelper
	def inline_form(link_text, query=link_text)
		form_tag("/", method:"post", class:"form-inline inline") do
			hidden = hidden_field_tag 'query', query #implicit field that will send the query (ie, query will go into \1)
			link = link_to link_text, "#", :onclick => "$(this).closest('form').submit()" #submit the closest form
			hidden + link
		end
	end

	def format_courselist(txt, course)
		#matches any strings that are like "ABC 123", and replaces them with inline_form
		last_dept = course.department.short #default to course's dept (ie if just "291")
		regex = /([A-Za-z]*)\s*(\d+[A-Za-z]*)/
		str = txt.gsub(regex) do |w|
			match = w.match regex
			link = w
			not_link = ""
			if match[1].empty? || match[1].strip == "or" || match[1].strip == "of" || match[1].strip == "and"
				not_link = match[1] + " "
				w = match[2]
				link = last_dept+" "+match[2].strip
			else
				last_dept = match[1]
			end
			not_link + inline_form(w,link).strip #strip off some whitespace that seems to come w the form
		end
		raw str
	end

	def format_instructors(txt)
		raw txt.split("; ").map {|i| inline_form(i, "instructor:#{i.split.first.downcase}") }.join("; ")
	end

	def enroll_bar_style(course)
		return "info" if course.no_cap?
		return "success" if course.enroll_percent < 75
		return "warning" if course.enroll_percent < 90
		return "danger"
	end

	def enroll_bar_precentage(course)
		return 100 if course.no_cap?
		course.enroll_percent
	end

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

	def formatted_time_and_day(course)
		days_of_week = {"M" => "Mon", "T" => "Tues", "W" => "Wed", "R" => "Thurs", "F" => "Fri", "S" => "Sat", "U" => "Sun"}
		# days is like "MWF". split into chars, map each one to the longer version, join with /, so Mon/Wed/Fri
		d = course.days.split("").map {|d| days_of_week[d]}.join("/")
		s = format_time(course.start_time.to_s)
		e = format_time(course.end_time.to_s)
		"#{d} #{s}-#{e}"
	end

	def enroll_ratio(course)
		"#{course.enroll}/#{course.no_cap? ? "∞" : course.cap}"
	end

	def should_split_cols(subcourses)
		subcourses.size > 3
	end

	def course_button_text(course, name)
		if course.can_enroll?
        	"Add #{name}"
      	elsif course.old?
      		course.term_and_year
        else
        	course.status_string
        end
	end
end
