class Ticket
	include Mongoid::Document
	field :contents, type: String
	field :email, type: String	
end
