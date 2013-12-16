class SchedulesController < ApplicationController
	def show
		@schedule = Schedule.find_by_id(params[:id])
	end
end
