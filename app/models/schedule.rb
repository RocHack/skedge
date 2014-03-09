require 'securerandom'

class Schedule
	include Mongoid::Document
	field :status, type: Integer

#	has_attached_file :image, :use_timestamp => false, :url => "system/:class/:attachment/:filename", :path => ":rails_root/public/system/:class/:attachment/:filename"

	def generate_secret_and_rid
		self.secret = SecureRandom.hex
		self.rid = Schedule.make_rid
	end

	def sections_description
		sections.map {|s| s.course.decorate.dept_and_cnum }.join(", ")
	end

	def js_data
		sections.map {|s| s.decorate.data }
	end
	
	def self.make_rid
		begin
			rid = ''
			1..4.times { rid += rand(10).to_s }
		end while !!Schedule.find_by_rid(rid)
		rid
	end
end
