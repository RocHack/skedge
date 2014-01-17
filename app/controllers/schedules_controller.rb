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
		@schedule = Schedule.find_by_rid(params[:rid])
		@side = false
		respond_to do |format|
			format.json {(!@schedule && raise_404) || (render json:@schedule.js_data.to_json)}
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
		@schedule = Schedule.find_by_id_and_secret(params[:id],params[:secret])
		if !@schedule
			render status:500
		else
			@schedule.image = decode_img(params[:img], @schedule.rid)
			@schedule.update_record_without_timestamping

			render json:{url:@schedule.image.url}
		end
	end

	def action(action, bookmark)
		if params[:id] == "new"
			@schedule = Schedule.create
		else
			@schedule = Schedule.find_by_id(params[:id])
			render status:500 if params[:secret] != @schedule.secret
		end
	
		if bookmark
			obj = Course.find_by_id(params[:obj_id])
			collection = @schedule.courses
		else
			obj = Section.find_by_crn(params[:obj_id])
			collection = @schedule.sections
		end

		if action == :delete
			collection.delete(obj)
		elsif action == :add
			collection << obj
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
