class FacebookController < ApplicationController
  def share_request
    a, b = params[:a], params[:b]
    
    # Assert a is really the user
    if !current_user || a != current_user.fb_id
      head 500
      return
    end

    # Assert b is really friends with the user
    #get "graph.facebook.com/v2.5/#{a}/friends/{b}"

    user_a = User.find_by(fb_id:a)
    user_b = User.find_by(fb_id:b)

    # Assert a & b aren't already sharing
    if user_a.share_users.include?(user_b)
      head 500
      return
    end

    # Will fail if the request already exists
    ShareRequest.create!(user_a: user_a,
                         user_b: user_b)
    head 200
  end

  def share_confirmation
    request = ShareRequest.find(params[:sr_id])

    a = request.user_a
    b = request.user_b

    # Assert requestee is really the user
    if b.fb_id != current_user.fb_id
      head 500
      return
    end

    a.share_users_forward << request.user_b
    a.save
    b.save
    request.destroy

    render json:{shareUsers:reactify_users(request.user_b.share_users)}
  end

  def register_user
    fb_id = params[:id]

    # Assert stuff

    user = current_user

    if !user
      user = User.find_by(fb_id:fb_id)
      if user
        ahoy.track("$old-user-fb", {id:user.id})
      else
        user = User.create
        ahoy.track("$new-user", {id:user.id, fb:true})
      end
    end

    user.fb_id = fb_id
    user.save

    render json:{status:200,
                 schedules:reactify_schedules(user.schedules),
                 userSecret:user.secret,
                 defaultSchedule:user.last_schedule.try(:yr_term)}
  end
end