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
 
  map.connect '/favors/search', :controller => 'favors', 
                                :action => 'search', 
                                :format => 'html', 
                                :conditions => { :method => :get }
 
  map.connect '/items/search', :controller => 'items', 
                               :action => 'search', 
                               :format => 'html', 
                               :conditions => { :method => :get }
 
  map.connect '/listings/add/:category', :controller => 'listings', 
                                :action => 'new_category', 
                                :format => 'html', 
                                :conditions => { :method => :get }
 
  map.connect '/listings/add/', :controller => 'listings', 
                                :action => 'new_category', 
                                :format => 'html', 
                                :conditions => { :method => :get }
                                          
  map.connect '/listings/search', :controller => 'listings', 
                                  :action => 'search', 
                                  :format => 'html', 
                                  :conditions => { :method => :get }
 
  map.connect '/listings/categories/:category', :controller => 'listings', 
                                                :action => 'index', 
                                                :format => 'html', 
                                                :conditions => { :method => :get }
                                  
  map.connect '/people/:id/contacts', :controller => 'contacts', 
                                      :action => 'index', 
                                      :format => 'html', 
                                      :conditions => { :method => :get }
 
  map.connect '/people/:id/friends', :controller => 'friends', 
                                     :action => 'index', 
                                     :format => 'html', 
                                     :conditions => { :method => :get }
  
  map.connect '/people/logout', :controller => 'people', 
                                :action => 'logout', 
                                :format => 'html', 
                                :conditions => { :method => :get }

  map.connect '/people/login', :controller => 'people', 
                               :action => 'login', 
                               :format => 'html', 
                               :conditions => { :method => :get }

  map.connect '/people/:id/inbox', :controller => 'messages', 
                                   :action => 'index', 
                                   :format => 'html', 
                                   :conditions => { :method => :get }
  
  map.connect '/people/:id/settings', :controller => 'settings', 
                                      :action => 'index', 
                                      :format => 'html', 
                                      :conditions => { :method => :get }
          
  map.connect '/people/:id/purse', :controller => 'purses', 
                                   :action => 'index', 
                                   :format => 'html', 
                                   :conditions => { :method => :get }         
                                                                                          
  map.connect '/people/:id/profile', :controller => 'profiles', 
                                     :action => 'index', 
                                     :format => 'html', 
                                     :conditions => { :method => :get }
                                
  map.connect '/people/:id/listings/:type', :controller => 'listings', 
                                            :action => 'index', 
                                            :format => 'html', 
                                            :conditions => { :method => :get }

  map.connect '/people/search', :controller => 'people', 
                                :action => 'search', 
                                :format => 'html', 
                                :conditions => { :method => :get }

  map.resources :favors                            
  map.resources :listings
  map.resources :people
  map.resources :items
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
  map.root :controller => "listings"
  
end
