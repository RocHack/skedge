class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_start_time

  def set_start_time
    @start_time = Time.now
    @side = true

    u = nil
    if cookies["s_id"]
      @rid, secret = cookies["s_id"].split("&")

      u = User.where(secret: secret).first
      @rid = nil if @rid && !u.schedules.where(rid:@rid).exists?
    end
    if u
      @user_json = u.skedge_json
      @rid ||= u.schedules.first.rid
    else
      @rid = "null"
      @user_json = "null"
    end
  end
end
