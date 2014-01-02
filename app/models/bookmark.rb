class Bookmark < ActiveRecord::Base
	belongs_to :course
	belongs_to :schedule
end
