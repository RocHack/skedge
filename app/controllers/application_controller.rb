class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_start_time

  def set_start_time
    @start_time = Time.now
    @side = true

    if cookies["s_id"]
  		s_id, secret = cookies["s_id"].split("&")
  		s = Schedule.where(_id: s_id).first
  		@my_schedule = s if s && s.secret == secret
  	end
  end
end
