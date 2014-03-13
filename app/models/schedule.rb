require 'securerandom'

class Schedule
	include Mongoid::Document
	include Mongoid::Paperclip

	field :secret, type: String
	field :rid, type: Integer

	field :bookmarks, type: Array, default: []
	field :enrollments, type: Array, default: []

	has_mongoid_attached_file :image, :use_timestamp => false, :url => "system/:class/:attachment/:filename", :path => ":rails_root/public/system/:class/:attachment/:filename"

	def generate_secret_and_rid
		self.secret = SecureRandom.hex
		self.rid = Schedule.make_rid
	end

	def js_data
		enrollments.map {|s| s.to_json }
	end

	def sections_description
		sections.map {|s| s.course.decorate.dept_and_cnum }.join(", ")
	end
	
	def self.make_rid
		begin
			rid = ''
			1..4.times { rid += rand(10).to_s }
		end while !!Schedule.where(rid:rid).exists?
		rid
	end
end
