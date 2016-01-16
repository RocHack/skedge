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
    
    render json:{requested:reactify_requests(user_a.sent_share_requests)}
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

    render json:{shareUsers:reactify_users(request.user_b.share_users)}
    
    request.destroy
  end

  def unshare
    # TODO: assert stuff
    
    user = current_user
    nonfriend = User.find_by(fb_id:params[:nonfriend])

    if user.share_users_forward.include?(nonfriend)
      user.share_users_forward.delete(nonfriend)
    else
      user.share_users_reverse.delete(nonfriend)
    end
    user.save

    render json:{shareUsers:reactify_users(user.share_users)}
  end

  def register_user
    fb_id = params[:id]

    # Assert stuff
    user = User.find_by(fb_id:fb_id)

    if !user
      if current_user
        if !current_user.fb_id
          current_user.fb_id = fb_id
          current_user.save
          ahoy.track("$old-user-fb", {id:user.id})
        end
      else
        user = User.create(fb_id:fb_id)
        ahoy.track("$new-user", {id:user.id, fb:true})
      end
    end

    render json:{status:200,
                 schedules:reactify_schedules(user.schedules),
                 userSecret:user.secret,
                 defaultSchedule:user.last_schedule.try(:yr_term),
                 shareUsers:reactify_users(user.share_users),
                 requests:reactify_requests(user.share_requests),
                 requested:reactify_requests(user.sent_share_requests)}
  end

  def get_public_sharing_friends
    public_friends = params[:friends].map do |i, friend|
      u = User.find_by(fb_id: friend["id"])
      u.public_sharing ? u : nil
    end.compact

    render json:{friends:reactify_users(public_friends)}
  end
end