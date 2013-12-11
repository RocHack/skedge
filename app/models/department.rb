class Department < ActiveRecord::Base
	has_many :courses
	validates :short, presence: true, uniqueness: { case_sensitive: false }

	def self.lookup(txt)
		where {short == txt.upcase}.first
	end
end
