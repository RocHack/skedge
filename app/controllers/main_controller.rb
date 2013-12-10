class MainController < ApplicationController
	def search_for_courses(query)
		return [] if !query

		query.strip!

		# check for a dept, (case insensitive)
		if query.size <= 3
			dept = Department.where("lower(short) = ?", query.downcase).first
			return dept.courses if dept
		end

		# check for a specific course (CSC 171)
		if (match = query.match /^([A-Za-z]*)\s*(\d+[A-Za-z]*)/)
			dept = Department.where("lower(short) = ?", match[1].downcase).first
			return Course.where({num:match[2].to_i, department:dept})
		end

		# otherwise just search titles
		Course.where("lower(name) = ?", query.downcase).first
	end

	def index
		@courses = search_for_courses(params[:query])
	end
end
