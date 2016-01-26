Rails.application.routes.draw do
  get '', to: 'search#search', constraints: ->(request) { request.params[:q] }
  root to: 'main#index'

  post 'bookmark', to: 'schedules#bookmark'
  post 'add_drop_sections', to: 'schedules#add_drop_sections'
  post 'change_last_schedule', to: 'schedules#change_last_schedule'
  post 'create_ticket', to: 'tickets#create'
  
  # Facebook

  get 'social', to: 'facebook#index'

  post 'fb_register_user', to: 'facebook#register_user'
  post 'fb_change_privacy', to: 'facebook#change_privacy'

  post 'fb_share_request', to: 'facebook#share_request'
  post 'fb_share_confirm', to: 'facebook#share_confirmation'
  post 'fb_unshare', to: 'facebook#unshare'

  get 'fb_get_public_sharing_friends', to: 'facebook#get_public_sharing_friends'
  get 'sharing_taking_course', to: 'facebook#sharing_taking_course'

  # Schedules

  get '/:rid' => 'schedules#show', :constraints => { :rid => /[0-9a-z]+/ }
end
