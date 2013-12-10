class MainController < ApplicationController
	def index
		query = params[:query]
		if query.present?
			dept = Department.where('short LIKE ?', "%#{query}%").first
			if dept
				@courses = dept.courses
			elsif (match = query.match /^([A-Za-z]*)\s*(\d+)/)
				dept = Department.where('short LIKE ?', "%#{match[1]}%").first
				@courses = Course.where({num:match[2].to_i, department:dept})
			else
				@courses = Course.where('name LIKE ?', "%#{query}%")
			end
		else
			@courses = []
		end
	end
end
