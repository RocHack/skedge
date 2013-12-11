class MainController < ApplicationController
	def search_for_courses(query)
		return [] if !query

		query.strip!

		type_search = Course::Type::Course
		name_search = ""
		dept_search = ""
		num_search = nil
		instructor_search = nil

		if (match = query.match /instructor:\s*([A-Za-z'-_]*).*/i)
			instructor_search = match[1]
			query = query.gsub(/instructor:\s*([A-Za-z'-_]*)/,"") #remove from the query
		end

		match = query.match /^([A-Za-z]*)\s*(\d+[A-Za-z]*|)\s*$/
		if match
			dept_search = match[1] if !match[1].empty?
			num_search = match[2] if !match[2].empty?
		else
			name_search = query
		end

		Course.joins{department}.where do
			[
				name_search.presence && name =~ "%#{name_search}%",
				dept_search.presence && department.short =~ "#{dept_search.upcase}%",
				instructors.presence && instructors =~ "%#{instructor_search}%",
				num_search.presence  && num == num_search,
				course_type.presence && course_type == type_search
			].compact.reduce(:&)
		end
	end

	def index
		@courses = search_for_courses(params[:query])
	end
end
