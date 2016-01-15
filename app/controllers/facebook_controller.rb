class FacebookController < ApplicationController
  include ReactHelper

  def share_request
    a, b = params[:a], params[:b]
    
    # Assert a is really the user
    if !current_user || a != current_user.fb_id
      head 500
      return
    end

    # Assert b is really friends with the user
    #get "graph.facebook.com/v2.5/#{a}/friends/{b}"

    # Will fail if the request already exists
    ShareRequest.create!(user_a: User.find_by(fb_id:a),
                         user_b: User.find_by(fb_id:b))
    head 200
  end

  def share_confirmation
    request = ShareRequest.find(params[:sr_id])

    # Assert requestee is really the user
    if request.user_b.fb_id != current_user.fb_id
      head 500
      return
    end

    request.user_a.share_users << request.user_b
    request.user_a.save
    request.user_b.save
    request.destroy
  end

  def register_user
    # Assert stuff

    user = current_user
    if !user
      user = User.create
      ahoy.track("$new-user", {id:user.id, fb:true})
    end
    user.fb_id = params[:id]
    user.save

    render json:{status:200,
                 schedules:reactify_schedules(user.schedules),
                 userSecret:user.secret}
  end
end