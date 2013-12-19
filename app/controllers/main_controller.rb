class MainController < ApplicationController
	def spring?
		true
	end

	def do_search(type_search, status_search, name_search, dept_search, num_search, instructor_search, term_search, c_low, c_hi, sort)
		Course.joins{department}.where do
			[
				c_low.presence && credits >= c_low,
				c_hi.presence && credits <= c_hi,
				num_search.presence && num =~ "#{num_search}%",
				term_search.presence && term == term_search,
				name_search.presence && name =~ "%#{name_search}%",
				dept_search.presence && department_id == dept_search,
				type_search.presence && course_type == type_search,
				instructor_search.presence && instructors =~ "%#{instructor_search}%"
			].compact.reduce(:&)
		end.order("year DESC, term #{spring? ? "DESC" : "ASC"}, department_id, #{sort}")
	end

	def credits_range(search)
		case search
		when "Any"
			return nil, nil
		when "1-2"
			return 1, 2
		when "3-4"
			return 3, 4
		when "5+"
			return 5, nil
		end
	end

	def search_for_courses(query)
		type_search = Course::Type::Course
		status_search = nil
		name_search = nil
		dept_search = nil
		num_search = nil
		instructor_search = nil

		term_search = Course::Term::Terms[params["term"].try(:capitalize)]
		credits_search = params["credits"]
		sort = {"Course #"=>"num", 
				"Start time (early to late)" => "min_start_time ASC", 
				"Start time (late to early)" => "max_start_time DESC", 
				"Class size (small to large)" => "min_enroll ASC"}[params["sort"]] || "num"

		instructor_regex = /instructor:\s*([A-Za-z'-_]*)/i
		if (match = query.match instructor_regex)
			instructor_search = match[1]
			params[:instructor_search] = instructor_search #keep so the view can filter out sections
			query = query.gsub(instructor_regex,"").strip #remove from the query
		end

		name_search = query
		match = query.match /^([A-Za-z]*)\s*(\d+[A-Za-z]*|)\s*$/
		if match && (match[1].size <= 3 || !match[2].empty?) #either the dept length is <= 3 OR we have some numbers
			dept_short = match[1] if !match[1].empty?
			if d = Department.lookup(dept_short)
				dept_search = d.id
				name_search = nil
			end
			num_search = match[2] if !match[2].empty?
		end

		c_lo, c_hi = credits_range(params["credits"])
		non_cancelled = (sort == "min_enroll ASC")
		s = do_search(type_search, status_search, name_search, dept_search, num_search, instructor_search, term_search, c_lo, c_hi, sort)
		if params["random"].presence
			s = [s.sample]
		end
		s.delete_if do |x|
			x.cancelled?
		end if non_cancelled
		s
	end

	def filter(courses)
		#TODO optimize!
		return courses
		courses.compact.delete_if do |c|
			sister = c.sister_course
			sister_exists = sister && (c.year < sister.year || (c.year == sister.year && c.term > sister.term)) && courses.include?(sister)
			sister_exists || c.research?
		end
	end

	def index
		@query = params[:query].try(:strip)
		@schedule = Schedule.first
		
		@courses = nil
		if @query && !@query.empty?
			@courses = filter(search_for_courses(@query))
		elsif params["random"].presence
			#random everything, but include stuff
			term_search = Course::Term::Terms[params["term"].try(:capitalize)]
			c_lo, c_hi = credits_range(params["credits"])
			@courses = Course.limit(1).where do
				[
					term_search.presence && term == term_search,
					c_lo.presence && credits >= c_lo,
					c_hi.presence && credits <= c_hi,
					course_type == Course::Type::Course,
					desc != nil
				].compact.reduce(:&)
			end.order("RANDOM()")
		else
			@depts = Department.all
		end
	end
end
