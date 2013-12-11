class MainController < ApplicationController
	def search_for_courses(query)
		type_search = Course::Type::Course
		status_search = nil
		name_search = nil
		dept_search = nil
		num_search = nil
		instructor_search = nil

		instructor_regex = /instructor:\s*([A-Za-z'-_]*)/i
		if (match = query.match instructor_regex)
			instructor_search = match[1]
			query = query.gsub(instructor_regex,"") #remove from the query
		end

		match = query.match /^([A-Za-z]*)\s*(\d+[A-Za-z]*|)\s*$/
		if match && (match[1].size <= 3 || !match[2].empty?) #either the dept length is <= 3 OR we have some numbers
			dept_search = match[1] if !match[1].empty?
			num_search = match[2] if !match[2].empty?
		else
			name_search = query
		end

		Course.joins{department}.where do
			[
				num_search.presence && num =~ "#{num_search.to_i.to_s}%",
				name_search.presence && name =~ "%#{name_search}%",
				dept_search.presence && department.short =~ "#{dept_search.upcase}%",
				type_search.presence && course_type == type_search,
				status_search.presence && status == status_search,
				instructor_search.presence && instructors =~ "%#{instructor_search}%"
			].compact.reduce(:&)
		end
	end

	def index
		@query = params[:query].try(:strip)
		@query = nil if @query && @query.empty?
		if @query
			@courses = search_for_courses(@query)
		else
			@depts = Department.all
		end
	end
end
