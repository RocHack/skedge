class Department < ActiveRecord::Base
	has_many :courses
	validates :short, presence: true, uniqueness: { case_sensitive: false }

	def self.lookup(short)
		where {short == short.upcase}.first
	end
end
