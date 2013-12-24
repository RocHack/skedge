class Schedule < ActiveRecord::Base
	has_and_belongs_to_many :sections

	def js_data
		sections.map {|s| s.decorate.data }
	end
end
