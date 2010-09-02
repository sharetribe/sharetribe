  Kassi::Application.routes.draw do |map|
  get "settings/profile"

  get "settings/notifications"

  get "comments/create"

  get "testimonials/new"

  get "testimonials/create"

  get "people/show"

  get "people/new"

  get "people/create"

  get "people/edit"

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
  #       get :short
  #       post :toggle
  #     end
  #
  #     collection do
  #       get :sold
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
  #       get :recent, :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  
  # Adds locale to every url right after the root path
  scope "(/:locale)" do
    resources :listings do
      collection do
        get :more_listings
        get :browse
      end
      resources :images, :controller => :listing_images
      resources :comments
    end
    resources :people do
      collection do
        get :check_username_availability
        get :check_email_availability
      end  
      resources :messages, :controller => :conversations do 
        collection do
          get :received
          get :sent
        end
        member do
          put :accept
          put :reject
          put :cancel
        end
        resources :messages
        resources :feedback, :controller => :testimonials do
          collection do
            put :skip
          end  
        end    
      end
      resource :settings do
        member do
          get :profile
          get :avatar
          get :account
          get :notifications
        end
      end      
    end
    resources :sessions
    resources :consent
  end
  
  # Some non-RESTful mappings
  match "/:locale/load" => "listings#load", :as => :load
  match "/:locale/offers" => "listings#offers", :as => :offers
  match "/:locale/requests" => "listings#requests", :as => :requests
  match "/:locale/people/:id/:type" => "people#show", :as => :person_listings
  match "/:locale/people/:person_id/messages/:conversation_type/:id" => "conversations#show", :as => :single_conversation
  match "/:locale/people/:person_id/messages" => "conversations#received", :as => :reply_to_listing
  match "/:locale/listings/:id/reply" => "conversations#new", :as => :reply_to_listing
  match "/:locale/listings/new/:type/:category" => "listings#new", :as => :new_request_category
  match "/:locale/listings/new/:type" => "listings#new", :as => :new_request
  match "/:locale/search" => "search#show"
  match "/:locale/logout" => "sessions#destroy", :as => :logout, :method => :delete
  match "/:locale/signup" => "people#new", :as => :sign_up
  match "/:locale/login" => "sessions#new", :as => :login
  match "/change_locale" => "i18n#change_locale"
  match '/:locale' => 'homepage#index'
  root :to => 'homepage#index'
  
end
