module SchedulesHelper
	def do_image_update
		return "" if !@schedule || !@user

		my_schedule = @user.schedules.where(rid:@schedule.rid).exists?
		if my_schedule && (!@schedule.image_file_name || @schedule.image_updated_at < @schedule.updated_at)
			"render_img(#{@schedule.rid}, window.location.hash=='#img');"
		else
			"if (window.location.hash=='#img') { window.location='#{@schedule.image.url}'; }"
		end
	end
end
