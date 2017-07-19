# coding: utf-8
Rails.application.routes.draw do

  namespace :mercury do
    resources :images
  end

  mount Mercury::Engine => '/'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  get "/robots.txt" => RobotsGenerator

  # URLs for sitemaps
  #
  # From Rails guide: By default dynamic segments don’t accept dots –
  # this is because the dot is used as a separator for formatted
  # routes. If you need to use a dot within a dynamic segment add a
  # constraint which overrides this – for example :id => /[^\/]+/
  # allows anything except a slash.
  #
  # That's why there's the constraints in generate URL to accept host
  # parameter with dots
  #
  get "/sitemap.xml.gz"                        => "sitemap#sitemap", format: :xml
  get "/sitemap/:sitemap_host/generate.xml.gz" => "sitemap#generate", format: :xml, :constraints => { sitemap_host: /[.\-\w]+/ }

  # A route for DV test file
  # A CA will check if there is a file in this route
  get "/:dv_file" => "domain_validation#index", constraints: {dv_file: /.*\.txt/}

  get "/design" => "design#design"

  # config/routes.rb
  if Rails.env.development?
    mount MailPreview => 'mail_view'
  end

  # Some non-RESTful mappings
  post '/webhooks/paypal_ipn' => 'paypal_ipn#ipn_hook', as: :paypal_ipn_hook
  post '/webhooks/plans' => 'plans#create'
  get '/webhooks/trials' => 'plans#get_trials'

  post '/bounces' => 'amazon_bounces#notification'

  get "/people/:person_id/inbox/:id", :to => redirect("/fi/people/%{person_id}/messages/%{id}")
  get "/listings/new/:type" => "listings#new", :as => :new_request_without_locale # needed for some emails, where locale part is already set
  get "/change_locale" => "i18n#change_locale", :as => :change_locale

  # Internal API
  namespace :int_api do
    post "/create_trial_marketplace" => "marketplaces#create"
    post "/prospect_emails" => "marketplaces#create_prospect_email"
  end

  # Harmony Proxy
  # This endpoint proxies the requests to Harmony and does authorization
  match '/harmony_proxy/*harmony_path' => 'harmony_proxy#proxy', via: :all

  # UI API, i.e. internal endpoints for dynamic UI that doesn't belong to under any specific controller
  get "/ui_api/topbar_props" => "topbar_api#props"

  # Keep before /:locale/ routes, because there is locale 'vi', which matches '_lp_preview'
  # and regexp anchors are not allowed in routing requirements.
  get '/_lp_preview' => 'landing_page#preview'

  locale_regex_string = Sharetribe::AVAILABLE_LOCALES.map { |l| l[:ident] }.concat(Sharetribe::REMOVED_LOCALES.to_a).join("|")
  locale_matcher = Regexp.new(locale_regex_string)
  locale_matcher_anchored = Regexp.new("^(#{locale_regex_string})$")

  # Conditional routes for custom landing pages
  get '/:locale/' => 'landing_page#index', as: :landing_page_with_locale, constraints: ->(request) {
    locale_matcher_anchored.match(request.params["locale"]) &&
      CustomLandingPage::LandingPageStore.enabled?(request.env[:current_marketplace]&.id)
  }
  get '/' => 'landing_page#index', as: :landing_page_without_locale, constraints: ->(request) {
    CustomLandingPage::LandingPageStore.enabled?(request.env[:current_marketplace]&.id)
  }

  # Conditional routes for search view if landing page is enabled
  get '/:locale/s' => 'homepage#index', as: :search_with_locale, constraints: ->(request) {
    locale_matcher_anchored.match(request.params["locale"]) &&
      CustomLandingPage::LandingPageStore.enabled?(request.env[:current_marketplace]&.id)
  }
  get '/s' => 'homepage#index', as: :search_without_locale, constraints: ->(request) {
    CustomLandingPage::LandingPageStore.enabled?(request.env[:current_marketplace]&.id)
  }

  # Default routes for homepage, these are matched if custom landing page is not in use
  # Inside this constraits are the routes that are used when request has subdomain other than www
  get '/:locale/' => 'homepage#index', :constraints => { :locale => locale_matcher }, as: :homepage_with_locale
  get '/' => 'homepage#index', as: :homepage_without_locale
  get '/:locale/s', to: redirect('/%{locale}', status: 307), constraints: { locale: locale_matcher }
  get '/s', to: redirect('/', status: 307)

  # error handling: 3$: http://blog.plataformatec.com.br/2012/01/my-five-favorite-hidden-features-in-rails-3-2/
  get '/500' => 'errors#server_error'
  get '/404' => 'errors#not_found', :as => :error_not_found
  get '/406' => 'errors#not_acceptable', :as => :error_not_acceptable
  get '/410' => 'errors#gone', as: :error_gone
  get '/community_not_found' => 'errors#community_not_found', as: :community_not_found

  resources :communities, only: [:new, :create]


  devise_for :people, only: :omniauth_callbacks, controllers: { omniauth_callbacks: "sessions" }

  get '/stripe_connect' => 'stripe_accounts#connect', as: :person_stripe_connect
  # Adds locale to every url right after the root path
  scope "(/:locale)", :constraints => { :locale => locale_matcher } do

    put '/mercury_update' => "mercury_update#update", :as => :mercury_update

    get "/transactions/op_status/:process_token" => "transactions#paypal_op_status", as: :paypal_op_status
    get "/transactions/transaction_op_status/:process_token" => "transactions#transaction_op_status", :as => :transaction_op_status
    get "/transactions/created/:transaction_id" => "transactions#created", as: :transaction_created
    get "/transactions/finalize_processed/:process_token" => "transactions#finalize_processed", as: :transaction_finalize_processed

    # All new transactions (in the future)
    get "/transactions/new" => "transactions#new", as: :new_transaction

    # preauthorize flow

    # Deprecated route (26-08-2016)
    get "/listings/:listing_id/book", :to => redirect { |params, request|
      "/#{params[:locale]}/listings/#{params[:listing_id]}/initiate?#{request.query_string}"
    }
    # Deprecated route (26-08-2016)
    post "/listings/:listing_id/booked"    => "preauthorize_transactions#initiated", as: :booked # POST request, no redirect

    get "/listings/:listing_id/initiate"   => "preauthorize_transactions#initiate", :as => :initiate_order
    post "/listings/:listing_id/initiated" => "preauthorize_transactions#initiated", :as => :initiated_order

    # free flow
    post "/listings/:listing_id/create_contact" => "free_transactions#create_contact", :as => :create_contact
    get "/listings/:listing_id/contact" => "free_transactions#contact", :as => :contact_to_listing

    get "/logout" => "sessions#destroy", :as => :logout
    get "/confirmation_pending" => "community_memberships#confirmation_pending", :as => :confirmation_pending
    get "/login" => "sessions#new", :as => :login
    get "/listing_bubble/:id" => "listings#listing_bubble", :as => :listing_bubble
    get "/listing_bubble_multiple/:ids" => "listings#listing_bubble_multiple", :as => :listing_bubble_multiple
    get '/:person_id/settings/payments/paypal_account' => 'paypal_accounts#index', :as => :paypal_account_settings_payment

    # community membership related actions

    get  '/community_memberships/pending_consent' => 'community_memberships#pending_consent', as: :pending_consent
    post '/community_memberships/give_consent'    => 'community_memberships#give_consent', as: :give_consent
    get  '/community_memberships/access_denied'   => 'community_memberships#access_denied', as: :access_denied

    get  '/community_memberships/check_email_availability_and_validity' => 'community_memberships#check_email_availability_and_validity'
    get  '/community_memberships/check_invitation_code'                 => 'community_memberships#check_invitation_code'


    namespace :paypal_service do
      resources :checkout_orders do
        collection do
          get :success
          get :cancel
          get :success_processed
        end
      end
    end

    namespace :admin do
      get '' => "getting_started_guide#index"
      
      # Payments
      get  "/payment_preferences"                     => "payment_preferences#index"
      # PayPal
      get  "/paypal_preferences"                      => "paypal_preferences#index"
      post "/paypal_preferences/preferences_update"   => "paypal_preferences#preferences_update"
      get  "/paypal_preferences/account_create"       => "paypal_preferences#account_create"
      get  "/paypal_preferences/permissions_verified" => "paypal_preferences#permissions_verified"
      # Stripe
      get  "/stripe_preferences"                      => "stripe_preferences#index"
      post "/stripe_preferences"                      => "stripe_preferences#update"

      # Settings
      get   "/settings" => "communities#settings",        as: :settings
      patch "/settings" => "communities#update_settings", as: :update_settings

      # Guide
      get "getting_started_guide"                        => "getting_started_guide#index",                  as: :getting_started_guide
      get "getting_started_guide/slogan_and_description" => "getting_started_guide#slogan_and_description", as: :getting_started_guide_slogan_and_description
      get "getting_started_guide/cover_photo"            => "getting_started_guide#cover_photo",            as: :getting_started_guide_cover_photo
      get "getting_started_guide/filter"                 => "getting_started_guide#filter",                 as: :getting_started_guide_filter
      get "getting_started_guide/payment"                => "getting_started_guide#payment",                as: :getting_started_guide_payment
      get "getting_started_guide/listing"                => "getting_started_guide#listing",                as: :getting_started_guide_listing
      get "getting_started_guide/invitation"             => "getting_started_guide#invitation",             as: :getting_started_guide_invitation

      # Details and look 'n feel
      get   "/look_and_feel/edit" => "communities#edit_look_and_feel",          as: :look_and_feel_edit
      patch "/look_and_feel"      => "communities#update_look_and_feel",        as: :look_and_feel
      get   "/details/edit"       => "community_customizations#edit_details",   as: :details_edit
      patch "/details"            => "community_customizations#update_details", as: :details
      get   "/new_layout"         => "communities#new_layout",                  as: :new_layout
      patch "/new_layout"         => "communities#update_new_layout",           as: :update_new_layout

      # Topbar menu
      get   "/topbar/edit"        => "communities#topbar",                      as: :topbar_edit
      patch "/topbar"             => "communities#update_topbar",               as: :topbar

      # Landing page menu
      get   "/landing_page"         => "communities#landing_page",                  as: :landing_page

      resources :communities do
        member do
          get :edit_welcome_email
          post :create_sender_address
          get :check_email_status
          post :resend_verification_email
          get :edit_text_instructions
          get :test_welcome_email
          get :social_media
          get :analytics
          put :social_media, to: 'communities#update_social_media'
          put :analytics, to: 'communities#update_analytics'
          delete :delete_marketplace

          # DEPRECATED (2016-08-26)
          # These routes are not in use anymore, don't use them
          # See new "Topbar menu" routes above, outside of communities resource
          get :topbar, to: redirect("/admin/topbar/edit")
          put :topbar, to: "communities#update_topbar" # PUT request, no redirect
          # also redirect old menu link requests to topbar
          get :menu_links, to: redirect("/admin/topbar/edit")
          put :menu_links, to: "communities#update_topbar" # PUT request, no redirect

          # DEPRECATED (2016-07-07)
          # These routes are not in use anymore, don't use them
          # See new "Guide" routes above, outside of communities resource
          get :getting_started, to: redirect('/admin/getting_started_guide')

          # DEPRECATED (2016-03-22)
          # These routes are not in use anymore, don't use them
          # See new routes above, outside of communities resource
          get :edit_details,       to: redirect("/admin/details/edit")
          put :update_details,     to: "community_customizations#update_details" # PUT request, no redirect
          get :edit_look_and_feel, to: redirect("/admin/look_and_feel/edit")
          put :edit_look_and_feel, to: "community_customizations#update_look_and_feel" # PUT request, no redirect

          # DEPRECATED (2016-03-22)
          # These routes are not in use anymore, don't use them
          # See the above :admin_settings routes, outside of :communities resource
          get :settings,       to: redirect("/admin/settings")
          put :update_settings # PUT request, no redirect
          get "getting_started_guide",                        to: redirect("/admin/getting_started_guide")
          get "getting_started_guide/slogan_and_description", to: redirect("/admin/getting_started_guide/slogan_and_description")
          get "getting_started_guide/cover_photo",            to: redirect("/admin/getting_started_guide/cover_photo")
          get "getting_started_guide/filter",                 to: redirect("/admin/getting_started_guide/filter")
          get "getting_started_guide/paypal",                 to: redirect("/admin/getting_started_guide/paypal")
          get "getting_started_guide/listing",                to: redirect("/admin/getting_started_guide/listing")
          get "getting_started_guide/invitation",             to: redirect("/admin/getting_started_guide/invitation")

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
        resource :paypal_preferences, only: :index do

          # DEPRECATED (2015-11-16)
          # Do not add new routes here.
          # See the above :paypal_preferences routes, outside of communities resource

          member do
            get :index,                to: redirect("/admin/paypal_preferences")
            post :preferences_update   # POST request, no redirect
            get :account_create,       to: redirect("/admin/paypal_preferences/account_create")
            get :permissions_verified, to: redirect("/admin/paypal_preferences/permissions_verified")
          end
        end
      end
      resources :custom_fields do
        collection do
          get :edit_price
          get :edit_location
          post :order
          put :update_price
          put :update_location
          get :edit_expiration
          put :update_expiration
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
      resources :listing_shapes do
        collection do
          post :order
        end
        member do
          get :close_listings
        end
      end
      resource :plan, only: [:show]
    end

    resources :invitations
    resources :user_feedbacks, :controller => :feedbacks
    resources :homepage do
      collection do
        get :sign_in
        post :join
      end
    end

    resources :listings do
      member do
        post :follow
        delete :unfollow
      end
      collection do
        get :new_form_content
        get :edit_form_content
        get :more_listings
        get :browse
        get :locations_json
        get :verification_required
      end
      resources :comments, :only => [:create, :destroy]
      resources :listing_images do
        collection do
          post :add_from_file
          put :add_from_url
          put :reorder
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

    devise_for :people, skip: :omniauth_callbacks, controllers: { confirmations: "confirmations", registrations: "people", omniauth_callbacks: "sessions"}, :path_names => { :sign_in => 'login'}
    devise_scope :person do
      # these matches need to be before the general resources to have more priority
      get "/people/confirmation" => "confirmations#show", :as => :confirmation
      put "/people/confirmation" => "confirmations#create"
      get "/people/sign_up" => redirect("/%{locale}/login")

      # List few specific routes here for Devise to understand those
      get "/signup" => "people#new", :as => :sign_up
      get '/people/auth/:provider/setup' => 'sessions#facebook_setup' #needed for devise setup phase hook to work

      resources :people, param: :username, :path => "", :only => :show, :constraints => { :username => /[_a-z0-9]{3,20}/ }

      resources :people, except: [:show] do
        collection do
          get :check_username_availability
          get :check_email_availability
          get :check_email_availability_and_validity
          get :check_invitation_code
          get :create_facebook_based
        end
      end

      resources :people, except: [:show], :path => "" do
        resources :listings do
          member do
            put :close
            put :move_to_top
            put :show_in_updates_email
          end
        end
        resources :person_messages

        resource :inbox, :only => [:show]

        resources :messages, :controller => :conversations do
          collection do
            # This is only a redirect from old route, changed 2014-09-11
            # You can clean up this later
            get :received, to: 'inboxes#show'
          end
          member do
            get :confirm, to: 'confirm_conversations#confirm'
            get :cancel, to: 'confirm_conversations#cancel'
            put :confirmation, to: 'confirm_conversations#confirmation' #TODO these should be under transaction
            get :accept_preauthorized, to: 'accept_preauthorized_conversations#accept'
            get :reject_preauthorized, to: 'accept_preauthorized_conversations#reject'
            put :acceptance_preauthorized, to: 'accept_preauthorized_conversations#accepted_or_rejected'
          end
          resources :messages
          resources :feedbacks, :controller => :testimonials do
            collection do
              put :skip
            end
          end
        end
        resource :paypal_account, only: [:index] do
          member do
            get :ask_order_permission
            get :ask_billing_agreement
            get :permissions_verified
            get :billing_agreement_success
            get :billing_agreement_cancel
          end
        end
        resource :stripe_account, only: [:show, :update, :create] do
          member do
            put :send_verification
            post :add_card
          end
        end

        resources :transactions, only: [:show, :new, :create]
        resource :settings do
          member do
            get :account
            get :notifications
            get :unsubscribe
            post :toggle_payment
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

    get "/:person_id/messages/:conversation_type/:id" => "conversations#show", :as => :single_conversation

    get '/:person_id/settings/profile', to: redirect("/%{person_id}/settings") #needed to keep old links working

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

  get "(/:locale)/people/:person_id(*path)" => redirect(id_to_username), :constraints => { :locale => locale_matcher, :person_id => /[a-zA-Z0-9_-]{22}/ }

  get "(/:locale)/:person_id(*path)" => redirect(id_to_username), :constraints => { :locale => locale_matcher, :person_id => /[a-zA-Z0-9_-]{22}/ }

  #keep this matcher last
  #catches all non matched routes, shows 404 and logs more reasonably than the alternative RoutingError + stacktrace

  match "*path" => "errors#not_found", via: :all
end
