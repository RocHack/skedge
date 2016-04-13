Rails.application.routes.draw do
  get '', to: 'search#search', constraints: ->(request) { request.params[:q] }
  root to: 'main#index'

  post 'bookmark', to: 'schedules#bookmark'
  post 'add_drop_sections', to: 'schedules#add_drop_sections'
  post 'change_last_schedule', to: 'schedules#change_last_schedule'
  post 'create_ticket', to: 'tickets#create'
  
  ##
  # Social
  #
  get 'social', to: 'social#index'

  post 'social/register_user', to: 'social#register_user'
  post 'social/change_privacy', to: 'social#change_privacy'

  post 'social/like', to: 'social#like'

  post 'social/share_request', to: 'social#share_request'
  post 'social/share_accept', to: 'social#share_accept'
  post 'social/unshare', to: 'social#unshare'

  get 'social/get_public_sharing_friends', to: 'social#get_public_sharing_friends'
  get 'social/courses', to: 'social#courses'

  ##
  # Schedules
  #
  get '/:rid' => 'schedules#show', :constraints => { :rid => /[0-9a-z]+/ }

  ##
  # "API"
  #
  get 'api/course', to: 'api#course'
  get 'api/courses', to: 'api#courses'
  get 'api/departments', to: 'api#departments'
end
