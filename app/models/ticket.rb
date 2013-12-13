class Ticket < ActiveRecord::Base
	validates :contents, presence: true
end
