class Ticket < ActiveRecord::Base
  module FeedbackType
    Bug = 1
    DataError = 2
    Question = 3
    Suggestion = 4
  end

  validates :comments, :feedback_type, presence: true
end