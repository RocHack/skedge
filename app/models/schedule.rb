class Schedule
	include Mongoid::Document
	include Mongoid::Paperclip

	field :rid, type: Integer
	field :term, type: Integer
	field :year, type: Integer

	field :enrollments, type: Array, default: []

	has_mongoid_attached_file :image, :use_timestamp => false, :url => "system/:class/:attachment/:filename", :path => ":rails_root/public/system/:class/:attachment/:filename"

	embedded_in :user

	def generate_rid
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
