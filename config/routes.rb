Skedge::Application.routes.draw do
  resources :schedules

  # You can have the root of your site routed with "root"
  # root 'main#index'
  # post '/' => 'main#index'
  # post '/ticket' => 'ticket#new'
  # get '/getemail' => 'main#get_email'

  # get '/schedule/new' => "schedules#new"
  # post '/schedule/add' => "schedules#add"
  # post '/schedule/delete' => "schedules#delete"

  # post '/schedule/bookmark/add' => "schedules#bookmark_add"
  # post '/schedule/bookmark/delete' => "schedules#bookmark_delete"

  # post '/schedule/set_image' => "schedules#set_image"

  get '/:rid' => 'schedules#show', :constraints => { :rid => /[0-9]+/ }

  root 'main#maintenance'
end
