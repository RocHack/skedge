require 'securerandom'

class Schedule < ActiveRecord::Base
	has_many :enrollments
	has_many :bookmarks
	has_many :sections, :through => :enrollments
	has_many :courses, :through => :bookmarks
	
	before_create :generate_secret

	has_attached_file :image#, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"

	def generate_secret
		self.secret = SecureRandom.hex
	end

	def js_data
		sections.includes(:course).map {|s| s.decorate.data }
	end
end
