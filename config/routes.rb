ClassRequestTool::Application.routes.draw do
  # Home
  root :to => 'welcome#index'

  resources :emails
  resources :item_attributes
  resources :notes
  resources :repositories
  resources :rooms
  resources :staff_involvements

  resources :assessments do
    collection do
      get 'export' # csv dump of assessments
    end
  end

  resources :courses do
    member do
      get 'summary'
      get 'recent_show'
      get 'take'
    end
    collection do
      get 'repo_select'
      get 'export'
      # AJAX helpers for course new/edit form
      get 'session_block'
      get 'section_block'
    end
  end
  get "/courses/:id/cancel", to: 'courses#cancel'

  devise_for :users
  resources :users

  resources :welcome do
    collection do
      get 'dashboard'
      get 'login'
    end
  end


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
