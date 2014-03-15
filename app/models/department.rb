class Department
	include Mongoid::Document
	field :short, type: String
	field :name, type: String
end