module ActiveRecord
  class Base

    def update_record_without_timestamping
      class << self
        def record_timestamps; false; end
      end

      save!

      class << self
        remove_method :record_timestamps
      end
    end

  end
end

class SchedulesController < ApplicationController
	def raise_404
		raise ActionController::RoutingError.new('Not Found')
	end

	def show
		@schedule = Schedule.find_by(rid:params[:rid])
		@side = false
		respond_to do |format|
			format.json { render json:@schedule.enrollments.to_json }
			format.html 
		end
	end

	def decode_img(img64, rid)
		img64["data:image/jpeg;base64,"] = ""
		data = StringIO.new(Base64.decode64(img64))
		data.class.class_eval { attr_accessor :original_filename, :content_type }
		data.original_filename = "#{rid}.jpg"
		data.content_type = "image/jpg"
		data
	end

	def set_image
		@schedule = Schedule.find_by(id:params[:id],secret:params[:secret])
		@schedule.image = decode_img(params[:img], @schedule.rid)
		@schedule.update_record_without_timestamping

		render json:{url:@schedule.image.url}
	end

	def action(action, bookmark)
		if params[:secret] == "new"
			@schedule = Schedule.create
		else
			@schedule = Schedule.find_by(secret:params[:secret])
		end

		course = Course.find(params[:course_id])
	
		if bookmark
			if action == :delete
				@schedule.bookmarks.delete(course)
			elsif action == :add
				@schedule.bookmarks << course
			end
		else
			if action == :delete
				@schedule.enrollments.delete_if {|e| e["crn"] == params[:crn].to_i}
			elsif action == :add
				#save the js data hash for superspeed efficiency
				data = course.relation(params[:course_type].to_i).where(crn:params[:crn]).first.data
				@schedule.enrollments << data
			end
		end

		@schedule.touch
		@schedule.save

		render json:@schedule
	end

	def add
		action :add, false
	end

	def delete
		action :delete, false
	end

	def bookmark_add
		action :add, true
	end

	def bookmark_delete
		action :delete, true
	end
end
