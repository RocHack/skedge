Rails.application.routes.draw do
  get '', to: 'search#search', constraints: ->(request) { request.params[:q] }
  root to: 'main#index'

  post 'bookmark', to: 'schedules#bookmark'
  post 'add_drop_sections', to: 'schedules#add_drop_sections'
  post 'change_last_schedule', to: 'schedules#change_last_schedule'
  post 'create_ticket', to: 'tickets#create'

  get '/:rid' => 'schedules#show', :constraints => { :rid => /[0-9a-z]+/ }

  # API
  get 'api/course', to: 'api#course'
end
