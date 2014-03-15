class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_start_time

  def set_start_time
    @start_time = Time.now
    @side = true

    @user = nil
    if cookies["s_id"]
      @rid, secret = cookies["s_id"].split("&")

      @user = User.where(secret: secret).first
      @rid = nil if @rid && @user && !@user.schedules.where(rid:@rid).exists?
    end
    if @user
      @user_json = @user.skedge_json
      @rid ||= @user.schedules.first.try(:rid) || "null"
    else
      @rid = "null"
      @user_json = "null"
    end
  end
end
