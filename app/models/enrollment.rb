class Enrollment < ActiveRecord::Base
	belongs_to :section
	belongs_to :schedule
end
