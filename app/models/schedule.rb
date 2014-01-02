require 'securerandom'

class Schedule < ActiveRecord::Base
	has_many :enrollments
	has_many :sections, :through => :enrollments
	before_create :generate_secret

	def generate_secret
		self.secret = SecureRandom.hex
	end

	def js_data
		sections.map {|s| s.decorate.data }
	end
end
