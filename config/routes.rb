require 'routes/subdomain'
require 'routes/api_request'

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
  # match ':controller(/:action(/:id(.:format)))
  
  scope :module => "api", :constraints => ApiRequest do
    resources :tokens, :only => :create
    resources :listings do
      resources :comments
    end
    resources :people do
      resources :conversations do
        member do
          post :messages, :controller => :conversations, :action => "new_message"
        end
      end
      resources :devices
      resources :listings
      resources :feedbacks, :controller => :testimonials
      resources :badges
    end

    match '/' => 'dashboard#api'    
  end
  
  # Adds locale to every url right after the root path
  scope "(/:locale)" do

    devise_for :people, :controllers => { :confirmations => "confirmations", :registrations => "people", :omniauth_callbacks => "sessions"}, :path_names => { :sign_in => 'login'} 
    devise_scope :person do  
      # these matches need to be before the general resources to have more priority
      get "/people/confirmation" => "confirmations#show", :as => :confirmation
      match "/people/password/edit" => "devise/passwords#edit"
      post "/people/password" => "devise/passwords#create"
      put "/people/password" => "devise/passwords#update"
      match "/people/sign_up" => redirect("/%{locale}/login")
           
      resources :people do
        collection do
          get :check_username_availability
          get :check_email_availability
          get :check_email_availability_for_new_tribe
          get :check_email_availability_and_validity
          get :check_email_validity
          get :check_invitation_code
          get :not_member
          get :cancel
          post :create_facebook_based
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
        resources :invitations
        resources :badges
        resources :testimonials
        resources :poll_answers
      end
      
      # List few specific routes here for Devise to understand those
      match "/signup" => "people#new", :as => :sign_up    
      match "/people/:id/:type" => "people#show", :as => :person_listings    
      
    end  

    namespace :admin do
      resources :feedbacks
      resources :news_items
      resources :communities
      resources :polls do
        collection do
          get :add_option
          get :remove_option
        end
        member do
          put :open
          put :close
        end
      end
    end
    resources :homepage do
      collection do
        get :sign_in
        get :not_member
        post :join
      end
    end
    resources :tribes, :controller => :communities do
      collection do 
        get :check_domain_availability
        get :change_form_language
        post :set_organization_email
        post :confirm_organization_email
      end
    end
    resources :community_memberships, :as => :tribe_memberships
    resources :listings do
      member do
        post :follow
        delete :unfollow
      end
      collection do
        get :more_listings
        get :browse
        get :random
      end
      resources :images, :controller => :listing_images
      resources :comments
    end

    resources :infos do
      collection do
        get :about
        get :how_to_use
        get :terms
        get :register_details
        get :news
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
        post :change_mistyped_email
      end
    end  
    resources :consent
    resource :sms do
      get :message_arrived
    end
    resources :news_items
    resources :statistics
  end
  
  # Some non-RESTful mappings
  match '/:locale/api' => "dashboard#api", :as => :api
  match '/:locale/faq' => "dashboard#faq", :as => :faq
  match '/:locale/pricing' => "dashboard#pricing", :as => :pricing
  match '/:locale/dashboard_login' => "dashboard#login", :as => :dashboard_login
  match '/wdc' => 'dashboard#wdc'
  match '/okl' => 'dashboard#okl'
  match '/omakotiliitto' => 'dashboard#okl'
  match '/:locale/admin' => 'admin/news_items#index', :as => :admin
  match '/badges/:style/:id.:format' => "badges#image"
  match "/people/:person_id/inbox/:id", :to => redirect("/fi/people/%{person_id}/messages/%{id}")
  match "/:locale/load" => "listings#load", :as => :load
  match "/:locale/loadmap" => "listings#loadmap", :as => :loadmap
  match "/:locale/offers" => "listings#offers", :as => :offers
  match "/:locale/requests" => "listings#requests", :as => :requests
  match "/:locale/offers/tag/:tag" => "listings#offers", :as => :offers_with_tag
  match "/:locale/requests/tag/:tag" => "listings#requests", :as => :requests_with_tag
  match "/:locale/people/:person_id/messages/:conversation_type/:id" => "conversations#show", :as => :single_conversation
  #match "/:locale/people/:person_id/messages" => "conversations#received", :as => :reply_to_listing
  match "/:locale/listings/:id/reply" => "conversations#new", :as => :reply_to_listing
  match "/:locale/listings/new/:type/:category" => "listings#new", :as => :new_request_category
  match "/:locale/listings/new/:type" => "listings#new", :as => :new_request
  match "/listings/new/:type" => "listings#new", :as => :new_request_without_locale # needed for some emails, where locale part is already set
  match "/:locale/search" => "search#show", :as => :search
  match "/:locale/logout" => "sessions#destroy", :as => :logout, :method => :delete
  match "/:locale/signup" => "people#new", :as => :sign_up
  match "/:locale/signup/check_captcha" => "people#check_captcha", :as => :check_captcha
  match "/:locale/confirmation_pending" => "sessions#confirmation_pending", :as => :confirmation_pending
  match "/:locale/login" => "sessions#new", :as => :login
  match "/change_locale" => "i18n#change_locale", :as => :change_locale
  match '/:locale/tag_cloud' => "tag_cloud#index", :as => :tag_cloud
  match "/:locale/offers/map/" => "listings#offers_on_map", :as => :offers_on_map
  match "/:locale/requests/map/" => "listings#requests_on_map", :as => :requests_on_map
  match "/api/query" => "listings#serve_listing_data", :as => :listings_data
  match "/:locale/listing_bubble/:id" => "listings#listing_bubble", :as => :listing_bubble
  match "/:locale/listing_bubble_multiple/:ids" => "listings#listing_bubble_multiple", :as => :listing_bubble_multiple
  match '/:locale/:page_type' => 'dashboard#campaign'
  
  # Inside this constraits are the routes that are used when request has subdomain other than www
  constraints(Subdomain) do
    match '/:locale/' => 'homepage#index'
    match '/' => 'homepage#index'
  end  
  
  # Below are the routes that are matched if didn't match inside subdomain constraints
  match '/:locale' => 'dashboard#index'
  
  root :to => 'dashboard#index'
  
end
