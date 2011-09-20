require 'subdomain'

Kassi::Application.routes.draw do

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
    devise_for :people, :controllers => { :confirmations => "confirmations" }
    
    namespace :admin do
      resources :feedbacks
    end
    resources :listings do
      collection do
        get :more_listings
        get :browse
        get :random
      end
      resources :images, :controller => :listing_images
      resources :comments
    end
    resources :people do
      collection do
        get :check_username_availability
        get :check_email_availability
        get :check_invitation_code
        get :not_member
      end
      member do 
        put :update_avatar
        put :activate
        put :deactivate
      end
      resources :listings do
        member do 
          put :close
        end  
      end  
      resources :messages, :controller => :conversations do 
        collection do
          get :received
          get :sent
          get :notifications
        end
        member do
          put :accept
          put :reject
          put :cancel
        end
        resources :messages
        resources :feedbacks, :controller => :testimonials do
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
      resources :badges
      resources :testimonials
    end
    resources :infos do
      collection do
        get :about
        get :how_to_use
        get :terms
        get :register_details
      end  
    end
    resource :terms do
      member do
        post :accept
      end  
    end    
    resources :sessions do
      collection do
        post :request_new_password
      end
    end  
    resources :consent
    resource :sms do
      get :message_arrived
    end
    resources :contact_requests do
      collection do
        get :thank_you
      end
    end
  end
  
  # Some non-RESTful mappings
  match '/badges/:style/:id.:format' => "badges#image"
  match "/people/:person_id/inbox/:id", :to => redirect("/fi/people/%{person_id}/messages/%{id}")
  match "/:locale/load" => "listings#load", :as => :load
  match "/:locale/loadmap" => "listings#loadmap", :as => :loadmap
  match "/:locale/offers" => "listings#offers", :as => :offers
  match "/:locale/requests" => "listings#requests", :as => :requests
  match "/:locale/offers/tag/:tag" => "listings#offers", :as => :offers_with_tag
  match "/:locale/requests/tag/:tag" => "listings#requests", :as => :requests_with_tag
  match "/:locale/people/:id/:type" => "people#show", :as => :person_listings
  match "/:locale/people/:person_id/messages/:conversation_type/:id" => "conversations#show", :as => :single_conversation
  match "/:locale/people/:person_id/messages" => "conversations#received", :as => :reply_to_listing
  match "/:locale/listings/:id/reply" => "conversations#new", :as => :reply_to_listing
  match "/:locale/listings/new/:type/:category" => "listings#new", :as => :new_request_category
  match "/:locale/listings/new/:type" => "listings#new", :as => :new_request
  match "/:locale/search" => "search#show", :as => :search
  match "/:locale/logout" => "sessions#destroy", :as => :logout, :method => :delete
  match "/:locale/signup" => "people#new", :as => :sign_up
  match "/:locale/signup/check_captcha" => "people#check_captcha", :as => :check_captcha
  match "/:locale/confirmation_pending" => "sessions#confirmation_pending", :as => :confirmation_pending
  match "/:locale/login" => "sessions#new", :as => :login
  match "/change_locale" => "i18n#change_locale"
  match '/:locale/tag_cloud' => "tag_cloud#index", :as => :tag_cloud
  match "/:locale/offers/map/" => "listings#offers_on_map", :as => :offers_on_map
  match "/:locale/requests/map/" => "listings#requests_on_map", :as => :requests_on_map
  match "/api/query" => "listings#serve_listing_data", :as => :listings_data
  match "/:locale/listing_bubble/:id" => "listings#listing_bubble", :as => :listing_bubble
  match "/:locale/listing_bubble_multiple/:ids" => "listings#listing_bubble_multiple", :as => :listing_bubble_multiple
  
  # Inside this constraits are the routes that are used when request has subdomain other than www
  constraints(Subdomain) do
    match '/:locale/' => 'homepage#index'
    match '/' => 'homepage#index'
  end  
  
  # Below are the routes that are matched if didn't match inside subdomain constraints
  match '/:locale' => 'dashboard#index'
  
  root :to => 'dashboard#index'
  
end
