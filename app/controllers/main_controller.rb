class MainController < ApplicationController
	def search_for_courses(query)
		return [] if !query

		query.strip!

		course_type = Course::Type::Course

		# check for a dept, (case insensitive)
		if query.size <= 3
			dept = Department.lookup(query)
			return dept.courses.where({course_type:course_type}) if dept
		end

		# check for a specific course (CSC 171)
		if (match = query.match /^([A-Za-z]*)\s*(\d+[A-Za-z]*)/)
			if match[1].empty?
				#just "172"
				Course.where({num:match[2].to_i, course_type:course_type})
			else
				dept = Department.lookup(match[1])
				if dept
					Course.where({num:match[2].to_i, department:dept, course_type:course_type})
				else
					[] #department wasn't found
				end
			end
		else
			# otherwise just search titles
			Course.where("(lower(name) LIKE ?) AND (course_type = ?)", "%#{query.downcase}%", course_type)
		end
	end

	def index
		@courses = search_for_courses(params[:query])
	end
end
