class Department < ActiveRecord::Base
	has_many :courses
	validates :short, presence: true, uniqueness: { case_sensitive: false }

	def self.lookup(txt)
		@@all ||= Department.all
		@@all.find do |d|
			d.short == txt.upcase
		end
	end
end
