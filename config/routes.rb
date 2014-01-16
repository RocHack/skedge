Skedge::Application.routes.draw do
  resources :schedules

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'main#index'
  post '/' => 'main#index'
  post '/ticket' => 'ticket#new'
  get '/getemail' => 'main#get_email'

  get '/schedule/new' => "schedules#new"
  post '/schedule/:id/add' => "schedules#add"
  post '/schedule/:id/delete' => "schedules#delete"

  post '/schedule/:id/bookmark/add' => "schedules#bookmark_add"
  post '/schedule/:id/bookmark/delete' => "schedules#bookmark_delete"

  post '/schedule/:id/set_image' => "schedules#set_image"

  get '/:id' => 'schedules#show', :constraints => { :id => /[0-9]+/ }

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
