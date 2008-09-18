# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '26c58c750ac36e1713e76184b3b8e162'

  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password

  before_filter :set_locale

  # Change current navigation state based on array containing new navi items.
  def save_navi_state(navi_items)
    session[:navi1] = navi_items[0] || session[:navi1]
    session[:navi2] = navi_items[1] || session[:navi2]
    session[:navi3] = navi_items[2] || session[:navi3]
    session[:navi4] = navi_items[3] || session[:navi4]
  end

  # Sets navigation state to "nothing selected".
  def clear_navi_state
    session[:navi1] = session[:navi2] = session[:navi3] = session[:navi4] = nil
  end
  
  # Fetch listings based on conditions
  def fetch_listings(conditions)
    @listing_amount = Listing.find(:all,
                             :order => 'id DESC', 
                             :conditions => conditions).size                                                    
    @listings = Listing.paginate :page => params[:page], 
                                 :per_page => per_page.to_i, 
                                 :order => 'id DESC', 
                                 :conditions => conditions                 
  end

  # Define how many listed items are shown per page.
  def per_page
    if params[:per_page].eql?("all")
      :all
    else  
      params[:per_page] || 10
    end
  end
  
  private 

  # Sets locale file used.
  def set_locale
    locale = params[:locale] || session[:locale] || 'fi'
    I18n.locale = locale
    I18n.populate do
      require "lib/locale/#{locale}.rb"
      unless (locale.eql?("en-US"))
        require "lib/locale/#{locale}_errors_actionview.rb"
        require "lib/locale/#{locale}_errors_actionsupport.rb"
        require "lib/locale/#{locale}_errors_activerecord.rb"
      end
    end
    session[:locale] = params[:locale] || session[:locale]
    # Require locale files for error messages
    require "lib/locale/#{locale}.rb"
  end

end
