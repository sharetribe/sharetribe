ActionController::Routing::Routes.draw do |map|


  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.                                                                                                                        

  map.resources :smerf_forms
  
  map.namespace :admin do |admin|
    admin.resources :feedbacks, :member => { :handle => :put }
  end
  map.resource :info, :collection => {
                                       :about => :get,
                                       :help => :get,
                                       :terms => :get
                                     }
  map.resource :session                            
  map.resource :cas_session
  map.resources :groups, :collection => { :search => :get }
  map.resources :listings, 
                :member => { 
                             :mark_as_interesting => :post, 
                             :mark_as_not_interesting => :delete,
                             :follow => :post,
                             :unfollow => :post,  
                           },
                :collection => { :search => :get, :random => :get } do |listing|
    listing.resource :image
    listing.resources :comments, :controller => :listing_comments 
    listing.resources :categories, :path_prefix => '/listings'
  end  
  map.resources :people, 
                :member => { :home => :get, :cancel_edit => :get }, 
                :collection => { :search => :get, :more_kassi_events => :get, :more_content_items => :get } do |person|
    person.resources :inbox, :controller => :conversations,
                             :collection => { 
                               :sent => :get,
                               :received_borrow_requests => :get,
                               :sent_borrow_requests => :get   
                              }
    person.resources :items, :member => { 
                                          :thank_for => :get,
                                          :mark_as_borrowed => :post,
                                          :view_description => :get,
                                          :hide_description => :get,
                                          :cancel_update => :get,
                                          :undo_destroy => :get,
                                          :borrow => :get
                                        },
                             :collection => { 
                                              :cancel_create => :get,
                                              :borrow => :get
                                            }
    person.resources :favors, :member => {
                                           :thank_for => :get,
                                           :mark_as_done => :post,
                                           :view_description => :get,
                                           :hide_description => :get,
                                           :cancel_update => :get,
                                           :undo_destroy => :get    
                                         },
                              :collection => { :cancel_create => :get }
    person.resource :purse
    person.resource :settings, :collection => { 
                                                :change_email => :put, 
                                                :change_password => :put 
                                              }
    person.resources :friends
    person.resources :contacts
    person.resources :kassi_events
    person.resources :listings, 
                     :member => { :close => :get, :mark_as_closed => :post }, 
                     :collection => { :interesting => :get, :comments => :get }
    person.resource :avatar, :member => { :upload_successful => :get}
    person.resources :requests, :member => { :accept => :post, :accept_redirect => :post, :reject => :post, :cancel => :post }
    person.resources :groups, :member => { :join => :post, :leave => :delete }              
  end
  map.resources :favors, :collection => { :search => :get, :search_by_title => :get }, :member => { :hide => :get }  
  map.resources :items, 
                :collection => { :search => :get, :search_by_title => :get }, 
                :member => { :hide => :get, :map => :get, :show_on_map => :get, :check_availability => :get }
  map.resource :search
  map.resources :transactions
  map.resource :consent, :collection => { :register => :get, :accept => :post, :accept_and_register => :post }
  
  map.root :controller => "people", :action => "home"
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
end
