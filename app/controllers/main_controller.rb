class MainController < ApplicationController
	def index
		query = params[:query]
		if query
			@courses = Course.where('name LIKE ?', "%#{query}%")
		else
			@courses = []
		end
	end
end
