class Course < ActiveRecord::Base
	belongs_to :department

	def enroll_percent
		return 100 if cap == 0
		enroll*100.0/cap
	end

	def bar_style
		return "success" if enroll_percent < 75 || cap == 0
		return "warning" if enroll_percent < 90
		"danger"
	end

	def format_time(time)
		if time.size == 3
			hour = time[0].to_i
			mins = time[1..2]
		else
			hour = time[0..1].to_i
			mins = time[2..3]
		end
		am = true
		if hour > 12
			hour = "#{hour - 12}"
			am = false
		end
		"#{hour}:#{mins}#{am ? "am" : "pm"}"
	end

	def formatted_time
		d = days.split("").map {|d| {"M" => "Mon", "T" => "Tues", "W" => "Wed", "R" => "Thurs", "F" => "Fri"}[d] }.join("/")
		s = format_time(start_time.to_s)
		e = format_time(end_time.to_s)
		"#{d} #{s}-#{e}"
	end

	def formatted_instructors
		instructors.split("; ").map {|i| "<a>#{i}</a>"}.join("; ")
	end

	def formatted_cross_listed
		cross_listed.gsub(/([A-Za-z]*\s+\d+[A-Za-z]*)/, '<a>\1</a>')
	end

	def time_tba?
		days == "TBA"
	end
end
