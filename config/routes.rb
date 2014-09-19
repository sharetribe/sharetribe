require 'routes/community_domain'
require 'routes/api_request'

Kassi::Application.routes.draw do

  namespace :mercury do
    resources :images
  end

  mount Mercury::Engine => '/'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  match "/robots.txt" => RobotsGenerator

  match "/design" => "design#design"

  # config/routes.rb
  if Rails.env.development?
    mount MailPreview => 'mail_view'
  end

  # Some non-RESTful mappings
  get '/webhooks/braintree' => 'braintree_webhooks#challenge'
  post '/webhooks/braintree' => 'braintree_webhooks#hooks'
  get '/webhooks/paypal_permissions' => 'paypal_webhooks#permissions_hook', as: :paypal_permissions_hook
  get '/webhooks/paypal_billing_agreement_success' => 'paypal_webhooks#billing_agreement_success_hook', as: :paypal_billing_agreement_success_hook
  get '/webhooks/paypal_billing_agreement_cancel' => 'paypal_webhooks#billing_agreement_cancel_hook', as: :paypal_billing_agreement_cancel_hook

  post '/bounces' => 'amazon_bounces#notification'

  match "/people/:person_id/inbox/:id", :to => redirect("/fi/people/%{person_id}/messages/%{id}")
  match "/listings/new/:type" => "listings#new", :as => :new_request_without_locale # needed for some emails, where locale part is already set
  match "/change_locale" => "i18n#change_locale", :as => :change_locale

  locale_matcher = Regexp.new(Rails.application.config.AVAILABLE_LOCALES.map(&:last).join("|"))

  # Inside this constraits are the routes that are used when request has subdomain other than www
  constraints(CommunityDomain) do
    match '/:locale/' => 'homepage#index', :constraints => { :locale => locale_matcher }
    match '/' => 'homepage#index'
  end

  # Below are the routes that are matched if didn't match inside subdomain constraints
  match '(/:locale)' => 'dashboard#index', :constraints => { :locale => locale_matcher }
  root :to => 'dashboard#index'

  match '/500' => 'errors#server_error'

  # Adds locale to every url right after the root path
  scope "(/:locale)", :constraints => { :locale => locale_matcher } do

    match '/mercury_update' => "mercury_update#update", :as => :mercury_update, :method => :put
    match '/dashboard_login' => "dashboard#login", :as => :dashboard_login
    match "/listings/:listing_id/preauthorize" => "listing_conversations#preauthorize", :as => :preauthorize_payment
    match "/listings/:listing_id/reply" => "listing_conversations#new", :as => :reply_to_listing
    match "/listings/:listing_id/contact" => "listing_conversations#contact", :as => :contact_to_listing
    match "/listings/new/:type/:category" => "listings#new", :as => :new_request_category
    match "/listings/new/:type" => "listings#new", :as => :new_request
    match "/logout" => "sessions#destroy", :as => :logout, :method => :delete
    match "/signup/check_captcha" => "people#check_captcha", :as => :check_captcha
    match "/confirmation_pending" => "sessions#confirmation_pending", :as => :confirmation_pending
    match "/login" => "sessions#new", :as => :login
    match "/listing_bubble/:id" => "listings#listing_bubble", :as => :listing_bubble
    match "/listing_bubble_multiple/:ids" => "listings#listing_bubble_multiple", :as => :listing_bubble_multiple
    match '/:person_id/settings/payments/braintree/new' => 'braintree_accounts#new', :as => :new_braintree_settings_payment
    match '/:person_id/settings/payments/braintree/show' => 'braintree_accounts#show', :as => :show_braintree_settings_payment
    match '/:person_id/settings/payments/braintree/create' => 'braintree_accounts#create', :as => :create_braintree_settings_payment
    match '/:person_id/settings/payments/paypal_account/new' => 'paypal_accounts#new', :as => :new_paypal_account_settings_payment
    match '/:person_id/settings/payments/paypal_account/show' => 'paypal_accounts#show', :as => :show_paypal_account_settings_payment
    match '/:person_id/settings/payments/paypal_account/create' => 'paypal_accounts#create', :as => :create_paypal_account_settings_payment

    scope :module => "api", :constraints => ApiRequest do
      resources :listings, :only => :index

      match 'api_version' => "api#version_check"
      match '/' => 'dashboard#api'
    end

    namespace :superadmin do
      resources :communities do
      end
    end

    namespace :admin do
      resources :communities do
        member do
          get :edit_details, to: 'community_customizations#edit_details'
          put :update_details, to: 'community_customizations#update_details'
          get :edit_look_and_feel
          put :edit_look_and_feel, to: 'communities#update_look_and_feel'
          get :edit_welcome_email
          get :edit_text_instructions
          get :test_welcome_email
          get :settings
          get :payment_gateways
          put :payment_gateways, to: 'communities#update_payment_gateway'
          post :payment_gateways, to: 'communities#create_payment_gateway'
          get :integrations
          put :integrations, to: 'communities#update_integrations'
          get :menu_links
          put :menu_links, to: 'communities#update_menu_links'
          put :update_settings
        end
        resources :transactions, controller: :community_transactions, only: :index
        resources :emails
        resources :community_memberships do
          member do
            put :ban
          end
          collection do
            post :promote_admin
            post :posting_allowed
          end
        end
        resource :paypal_account, :controller => :paypal_accounts
      end
      resources :custom_fields do
        collection do
          get :add_option
          get :edit_price
          get :edit_location
          post :order
          put :update_price
          put :update_location
        end
      end
      resources :categories do
        member do
          get :remove
          delete :destroy_and_move
        end
        collection do
          post :order
        end
      end
    end

    resources :contact_requests
    resources :invitations
    resources :user_feedbacks, :controller => :feedbacks
    resources :homepage do
      collection do
        get :sign_in
        get :not_member
        post :join
      end
    end
    resources :community_memberships, :as => :tribe_memberships do
      collection do
        get :access_denied
      end
    end
    resources :listings do
      member do
        post :follow
        delete :unfollow
      end
      collection do
        get :more_listings
        get :browse
        get :random
        get :locations_json
        get :verification_required
      end
      resources :comments
      resources :listing_images do
        collection do
          post :add_from_file
          put :add_from_url
        end
      end
    end

    resources :listing_images do
      member do
        get :image_status
      end
      collection do
        post :add_from_file
        put :add_from_url
      end
    end

    resources :infos do
      collection do
        get :about
        get :how_to_use
        get :terms
        get :privacy
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
    resources :statistics

    devise_for :people, :controllers => { :confirmations => "confirmations", :registrations => "people", :omniauth_callbacks => "sessions"}, :path_names => { :sign_in => 'login'}
    devise_scope :person do
      # these matches need to be before the general resources to have more priority
      get "/people/confirmation" => "confirmations#show", :as => :confirmation
      put "/people/confirmation" => "confirmations#create"
      match "/people/password/edit" => "devise/passwords#edit"
      post "/people/password" => "devise/passwords#create"
      put "/people/password" => "devise/passwords#update"
      match "/people/sign_up" => redirect("/%{locale}/login")

      # List few specific routes here for Devise to understand those
      match "/signup" => "people#new", :as => :sign_up
      match '/people/auth/:provider/setup' => 'sessions#facebook_setup' #needed for devise setup phase hook to work

      resources :people, :only => :index
      resources :people, :path => "", :only => :show, :constraints => { :id => /[_a-z0-9]+/ }

      resources :people, :constraints => { :id => /[_a-z0-9]+/ } do
        collection do
          get :check_username_availability
          get :check_email_availability
          get :check_email_availability_and_validity
          get :check_invitation_code
          get :not_member
          get :cancel
          get :create_facebook_based
          get :fetch_rdf_profile
        end
      end

      resources :people, :path => "" do
        member do
          put :activate
          put :deactivate
        end
        resources :listings do
          member do
            put :close
            put :move_to_top
            put :show_in_updates_email
          end
          resources :listing_conversations do
            collection do
              post :create_contact
              post :preauthorized
            end
          end
        end
        resources :person_messages
        resources :messages, :controller => :conversations do
          collection do
            get :received
          end
          member do
            get :accept, to: 'accept_conversations#accept'
            get :reject, to: 'accept_conversations#reject'
            put :acceptance, to: 'accept_conversations#acceptance'
            get :confirm, to: 'confirm_conversations#confirm'
            get :cancel, to: 'confirm_conversations#cancel'
            put :confirmation, to: 'confirm_conversations#confirmation'
            get :accept_preauthorized, to: 'accept_preauthorized_conversations#accept'
            get :reject_preauthorized, to: 'accept_preauthorized_conversations#reject'
            put :acceptance_preauthorized, to: 'accept_preauthorized_conversations#accepted', constraints: ParamsConstraints.new({listing_conversation: {status: "paid"}})
            put :acceptance_preauthorized, to: 'accept_preauthorized_conversations#rejected', constraints: ParamsConstraints.new({listing_conversation: {status: "rejected"}})
          end
          resources :messages
          resources :feedbacks, :controller => :testimonials do
            collection do
              put :skip
            end
          end
          resources :payments do
            member do
              get :done
            end
          end
          resources :braintree_payments
        end
        resource :paypal_account, only: [:new, :show, :create]
        resource :checkout_account, only: [:new, :show, :create]
        resource :settings do
          member do
            get :profile
            get :account
            get :notifications
            get :payments
            get :unsubscribe
          end
        end
        resources :testimonials
        resources :emails do
          member do
            post :send_confirmation
          end
        end
        resources :followers
        resources :followed_people
      end # people

    end # devise scope person

    match "/:person_id/messages/:conversation_type/:id" => "conversations#show", :as => :single_conversation

  end # scope locale

  id_to_username = Proc.new do |params, req|
    username = Person.find(params[:person_id]).try(:username)
    locale = params[:locale] + "/" if params[:locale]
    if username
      "/#{locale}#{username}#{params[:path]}"
    else
      "/404"
    end
  end

  match "(/:locale)/people/:person_id(*path)" => redirect(id_to_username), :constraints => { :locale => locale_matcher, :person_id => /[a-zA-Z0-9_-]{20,}/ }

end
