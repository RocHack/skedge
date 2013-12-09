class MainController < ApplicationController
	def index
		query = params[:query]
		if query
			@courses = ["abc", "def"]#Course.where('name LIKE ?', "%#{query}%")
		else
			@courses = []
		end
	end
end
