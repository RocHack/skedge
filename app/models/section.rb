class Section
	module Status
		Open = 0
		Closed = 1
		Cancelled = 2

		Statuses = {"Open" => Open, "Closed" => Closed, "Cancelled" => Cancelled}
	end

	module Term
		Fall = 0
		Spring = 1
		Both = 2

		Terms = {"Fall" => Fall, "Spring" => Spring}
	end

	module Type
		Course = 0
		Lab = 1
	    Recitation = 2
	    LabLecture = 3
	    Workshop = 4
	    
	    Types = {"LAB" => Lab, "REC" => Recitation, "L/L" => LabLecture, "WRK" => Workshop}
	end


	include Mongoid::Document
	field :status, type: Integer
	field :instructors, type: Array
	field :building, type: String
	field :room, type: String
	field :days, type: String
	field :start_time, type: Integer
	field :end_time, type: Integer
	field :sec_enroll, type: Integer
	field :sec_cap, type: Integer
	field :tot_enroll, type: Integer
	field :tot_cap, type: Integer
	field :crn, type: Integer
	field :section_type, type: Integer
	embedded_in :course

	def hour(start_or_end)
		send(:"#{start_or_end}_time").to_s.rjust(4,"0")[0..1].to_i #first two, accounting for 3-digits, ie, "940"
	end

	def minutes(start_or_end)
		send(:"#{start_or_end}_time").to_s[-2..-1].to_i #last 2
	end

	def time_in_hours(start_or_end)
		hour(start_or_end)+minutes(start_or_end)/60.0
	end

	def duration
		time_in_hours(:end) - time_in_hours(:start)
	end

	def cap
		tot_cap || sec_cap
	end

	def enroll
		tot_enroll || sec_enroll
	end

	def no_cap?
		cap == 0 || cap == nil
	end

	def closed?
		status == Status::Closed
	end

	def cancelled?
		status == Status::Cancelled
	end

	def enroll_percent
		enroll*100.0/cap
	end

	def time_tba?
		days == "TBA"
	end

	def multiple_instructors?
		instructors.size > 1
	end

	def data
		{
			id:course.id.to_s,
			location:"#{building} #{room}",
			crn:crn,
	        days:days,
	        title:course.title,
	        time:decorate.time(false),
	        start_time:start_time,
	        end_time:end_time,
	        time_in_hours:time_in_hours(:start),
	        duration:duration,
	        dept:course.dept,
	        num:course.number,
	        popover_content:decorate.popover_content.gsub("\n","<br>"),
	        popover_title:decorate.popover_title,
	        course_type:section_type
      	}
    end
end
