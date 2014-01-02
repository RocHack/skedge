class SchedulesController < ApplicationController
	def raise_404
		raise ActionController::RoutingError.new('Not Found')
	end

	def show
		@schedule = Schedule.find_by_id(params[:id]) || raise_404
		@side = false
		respond_to do |format|
			format.json {render json:@schedule.js_data.to_json}
			format.html 
		end
	end

	def action(action, bookmark)
		if params[:id] == "new"
			@schedule = Schedule.create
		else
			@schedule = Schedule.find_by_id(params[:id])
			render status:500 if params[:secret] != @schedule.secret
		end
	
		if bookmark
			obj = Course.find_by_id(params[:obj_id])
			collection = @schedule.courses
		else
			obj = Section.find_by_crn(params[:obj_id])
			collection = @schedule.sections
		end

		if action == :delete
			collection.delete(obj)
		elsif action == :add
			collection << obj
		end

		@schedule.save

		render json:@schedule
	end

	def add
		action :add, false
	end

	def delete
		action :delete, false
	end

	def bookmark_add
		action :add, true
	end

	def bookmark_delete
		action :delete, true
	end
end
