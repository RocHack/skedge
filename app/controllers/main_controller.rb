class MainController < ApplicationController
	def spring?
		true
	end

	def do_search(type_search, status_search, name_search, dept_search, num_search, instructor_search, term_search, credits_search, sort)
		Course.joins{department}.where do
			[
				(case credits_search
				when "Any"
					nil
				when "1-2"
					(credits == 1) | (credits == 2)
				when "3-4"
					(credits == 3) | (credits == 4)
				when "5+"
					(credits > 4)
				end),
				num_search.presence && num =~ "#{num_search}%",
				term_search.presence && term == term_search,
				name_search.presence && name =~ "%#{name_search}%",
				dept_search.presence && department.short =~ "#{dept_search.upcase}%",
				type_search.presence && course_type == type_search,
				instructor_search.presence && instructors =~ "%#{instructor_search}%"
			].compact.reduce(:&)
		end.order("year DESC, term #{spring? ? "DESC" : "ASC"}, department_id, #{sort}")
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
				"Start time (early to late)" => "num",#"start_time ASC", 
				"Start time (late to early)" => "num",#"start_time DESC", 
				"Class size (small to large)" => "num"}[params["sort"]]

		instructor_regex = /instructor:\s*([A-Za-z'-_]*)/i
		if (match = query.match instructor_regex)
			instructor_search = match[1]
			params[:instructor_search] = instructor_search #keep so the view can filter out sections
			query = query.gsub(instructor_regex,"") #remove from the query
		end

		match = query.match /^([A-Za-z]*)\s*(\d+[A-Za-z]*|)\s*$/
		if match && (match[1].size <= 3 || !match[2].empty?) #either the dept length is <= 3 OR we have some numbers
			dept_search = match[1] if !match[1].empty?
			num_search = match[2] if !match[2].empty?
		else
			name_search = query
		end

		s = do_search(type_search, status_search, name_search, dept_search, num_search, instructor_search, term_search, credits_search, sort)
		if params["random"].presence
			s = [s.sample]
		end
		s
	end

	def filter(courses)
		#TODO optimize!
		courses.delete_if do |c|
			sister = c.sister_course
			sister && courses.include?(sister) && (c.year < sister.year || (c.year == sister.year && c.term > sister.term))
		end
	end

	def index
		@query = params[:query].try(:strip)
		
		@courses = nil
		if @query && !@query.empty?
			@courses = filter(search_for_courses(@query))
		elsif params["random"].presence
			#random everything
			@courses = Course.limit(1).where {(course_type == Course::Type::Course) & (desc != nil)}.order("RANDOM()")
		else
			@depts = Department.all
		end
	end
end
