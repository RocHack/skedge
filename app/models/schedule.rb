class Schedule
	include Mongoid::Document
	include Mongoid::Paperclip

	include Mongoid::Timestamps::Updated

	field :rid, type: Integer
	field :term, type: Integer
	field :year, type: Integer

	field :enrollments, type: Array, default: []

	has_mongoid_attached_file :image, :use_timestamp => false, :url => "system/:class/:attachment/:filename", :path => ":rails_root/public/system/:class/:attachment/:filename"
	do_not_validate_attachment_file_type :image

	embedded_in :user

	def generate_rid
		self.rid = Schedule.make_rid
	end

	def js_data
		enrollments.map {|s| s.to_json }
	end

	def description
		"#{['Fall', 'Spring', 'Summer', 'Winter'][term]} #{year}"
	end

	def sections_description
		enrollments.map {|s| s["dept"]+" "+s["num"] }.join(", ")
	end

	def total_credits
		enrollments.inject(0) {|sum, e| sum + e["popover_title"].match(/(\d+) credit/)[1].to_i }
	end
	
	def self.make_rid
		begin
			rid = ''
			1..4.times { rid += rand(10).to_s }
		end while !!Schedule.where(rid:rid).exists?
		rid
	end
end
