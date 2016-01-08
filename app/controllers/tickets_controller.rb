class TicketsController < ApplicationController
  def create
    feedback_table = {
      "bug" => Ticket::FeedbackType::Bug,
      "data" => Ticket::FeedbackType::DataError,
      "question" => Ticket::FeedbackType::Question,
      "suggestion" => Ticket::FeedbackType::Suggestion
    }

    p = ticket_params
    if p[:feedback_type]
      p[:feedback_type] = feedback_table[p[:feedback_type]]
    end

    @ticket = Ticket.create(p)
    head :ok
  end

  private
  def ticket_params
    params.require(:ticket).permit(:feedback_type, :email, :data_info, :comments)
  end
end