class SchedulesController < ApplicationController
	def raise_404
		raise ActionController::RoutingError.new('Not Found')
	end

	def show
		rid = params[:rid].to_i
		user = User.where('schedules.rid' => rid).first
		@schedule = user.schedules.find_by(rid:rid)
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
		if !(s=cookies["s_id"])
			render status:500
			return
		end

		secret = s.split("&").last
		@schedule = User.find_by(secret:secret).schedules.find_by(rid:params[:rid])

		@schedule.image = decode_img(params[:img], @schedule.rid)

		@schedule.timeless.save

		render json:{url:@schedule.image.url}
	end

	def action(action, bookmark)
		if cookies["s_id"]
			secret = cookies["s_id"].split("&")[1]
			@user = User.find_by(secret:secret)
		else
			@user = User.new
			@user.generate_secret
		end

		course = Course.find(params[:course_id])

		if bookmark
			if action == :delete
				@user.bookmarks.delete_if {|e| e["id"] == params[:course_id]}
			elsif action == :add
				@user.bookmarks << {title:course.title,number:course.decorate.dept_and_cnum,id:course.id.to_s}
			end
		else
			@schedule = @user.schedules.where(term:course.term, year:course.year).first

			if !@schedule
				@schedule = Schedule.new(term:course.term, year:course.year)
				@schedule.generate_rid
				@user.schedules << @schedule
			end

			if action == :delete
				@schedule.enrollments.delete_if {|e| e["crn"] == params[:crn].to_i}
			elsif action == :add
				#save the js data hash for superspeed efficiency
				data = course.relation(params[:course_type].to_i).where(crn:params[:crn]).first.data
				@schedule.enrollments << data
			end

			@schedule.touch
		end

		@user.save

		render json:@user.skedge_json(bookmark ? nil : @schedule.rid)
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
