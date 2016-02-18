class SocialController < ApplicationController
  layout 'main'

  def index
    @social_visible = true
  end

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

  def share_accept
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

    render json:reactify_social(current_user)
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

    render json:reactify_social(current_user) 
  end

  def change_privacy
    # TODO: assert stuff?

    user = current_user
    user.public_sharing = (params[:option].to_i == 0)
    user.save

    head 200
  end

  def like
    # TODO: assert stuff?

    user = current_user
    course = Course.find(params[:id])
    if user.liked_courses.include? course
      user.liked_courses.delete course
    else
      user.liked_courses << course
    end
    user.save

    head 200
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

    render json:{status: 200,
                 social: reactify_social(user),
                 user: {
                  schedules:reactify_schedules(user.schedules),
                   userSecret:user.secret,
                   defaultSchedule:user.last_schedule.try(:yr_term)
                  }
                }
  end

  def sharing_users(friends, user, include_private=true)
    return [] if !friends
    friends.map do |i, friend|
      u = User.find_by(fb_id: friend["id"])
      private_sharing = user.share_users.include?(u)
      if ((u.public_sharing && (include_private || !private_sharing)) || #mutex
          (include_private && private_sharing))
        u
      else
        nil
      end
    end.compact
  end

  def get_public_sharing_friends
    user = current_user
    friends = sharing_users(params[:friends], user, false) #don't get privately sharing

    # Also update # of friends if requested
    if params[:updateFriendCount] == "true"
      user.friend_count = params[:friends].count
      user.save
    end

    render json:{friends:reactify_users(friends)}
  end

  def courses
    user = current_user
    friends = sharing_users(params[:friends], user) #also get privately sharing

    taking = []
    like = []

    Course.find(params[:course_id]).all_offerings.each do |course|
      taking += friends.select do |friend|
        schedule = friend.schedules.find_by(yr_term:course.yr_term)
        schedule && schedule.sections.collect(&:course).include?(course)
      end

      like += friends.select do |friend|
        friend.liked_courses.include?(course)
      end
    end

    render json:{taking:reactify_users(taking.uniq), like: reactify_users(like.uniq)}
  end
end