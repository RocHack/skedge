class TicketController < ApplicationController
	respond_to :js

	def new
		@ticket = Ticket.create(ticket_params)
		respond_to do |format|
			format.js { render :layout => false }
		end
	end

	private
	def ticket_params
		params.require(:ticket).permit(:email, :contents)
	end
end
