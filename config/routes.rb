ClassRequestTool::Application.routes.draw do
  get "custom_text/index"

  # Home
  root :to => 'welcome#show'

  resources :emails
  resources :item_attributes
  resources :notes
  
  get       '/repository/staff',          to: 'repositories#staff'
  get       '/repository/staff_services', to: 'repositories#staff_services'
  get       '/repository/technologies',   to: 'repositories#technologies'
  resources :repositories

  resources :rooms
  resources :staff_services
  resources :attached_images, :only => [:index, :create, :destroy]

  resources :assessments do
    collection do
      get 'export' # csv dump of assessments
    end
  end

  resources :courses do
    member do
      get 'recent_show'
      get 'take'
    end
    collection do
      get 'repo_select'
      get 'export'
      # AJAX helpers for course new/edit form
      get 'new_section_or_session_block'
      get 'dashboard'
    end
  end
  get "/courses/:id/cancel",    to: 'courses#cancel'
  get "/courses/:id/uncancel",  to: 'courses#uncancel'

  devise_for :users,
    :controllers => {
      :registrations => 'custom_devise/registrations'
    }
  resources :users

  resources :welcome do
    collection do
      get 'login'
    end
  end
  
  namespace :admin do
    resources :customizations,                  only: [:update]
    resources :custom_texts,                    only: [:index, :create, :update, :destroy]

    resources :affiliates,                      only: [:create, :update, :destroy]
    post      'affiliates/update_positions',    to: 'affiliates#update_positions'               # AJAX route

    get   'reports',                            to: 'admin#report_form'
    post  'build_report',                       to: 'admin#build_report'
    post  'build_report',                       to: 'admin#build_report'
    post  'csv/export',                         to: 'admin#csv_export'
    get   'create-graph',                       to: 'admin#create_graph'
    get   'dashboard',                          to: 'admin#dashboard'
    get   'localize',                           to: 'admin#localize'
    get   'send_test_email',                    to: 'admin#send_test_email'
    get   'update_stats',                       to: 'admin#update_stats'
    get   'harvard_colors',                     to: 'admin#harvard_colors'
    get   'clear_mail_queue',                   to: 'admin#clear_mail_queue'
    namespace :notifications do
      get 'preview(/:action)',                  to: 'notification#:action'
      get 'toggle',                             to: 'notification#toggle_notifications'   # AJAX route 
    end
  end


end
