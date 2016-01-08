class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user

  def current_user
    _, secret = cookies["s_id"].try(:split, "&")
    secret && (User.find_by(secret: secret))# || raise("Tried to access a user with secret that doesn't exist"))
  end
end
