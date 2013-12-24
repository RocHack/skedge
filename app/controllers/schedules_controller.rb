class SchedulesController < ApplicationController
	def raise_404
		raise ActionController::RoutingError.new('Not Found')
	end

	def show
		@schedule = Schedule.find_by_id(params[:id]) || raise_404
		respond_to do |format|
			format.json {render json:@schedule.js_data.to_json}
			format.html 
		end
	end

	def action(action)
		if params[:id] == "new"
			@schedule = Schedule.create
		else
			@schedule = Schedule.find_by_id(params[:id])
			render status:500 if params[:secret] != @schedule.secret
		end
	
		section = Section.find_by_crn(params[:crn])
		if action == :delete
			@schedule.sections.delete(section)
		elsif action == :add
			@schedule.sections << section
		end
		@schedule.save

		render json:@schedule
	end

	def add
		action :add
	end

	def delete
		action :delete
	end
end
