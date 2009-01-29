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
  before_filter :fetch_logged_in_user
  before_filter :count_new_arrived_items
  before_filter :set_up_feedback_form

  # Change current navigation state based on array containing new navi items.
  def save_navi_state(navi_items)
    session[:navi1] = navi_items[0] || session[:navi1]
    session[:navi2] = navi_items[1] || session[:navi2]
    session[:navi3] = navi_items[2] || session[:navi3]
    session[:navi4] = navi_items[3] || session[:navi4]
    session[:profile_navi] = navi_items[4] || session[:profile_navi]
  end

  # Sets navigation state to "nothing selected".
  def clear_navi_state
    session[:navi1] = session[:navi2] = session[:navi3] = session[:navi4] = session[:navi_profile] = nil
  end
  
  # Fetch listings based on conditions
  def fetch_listings(conditions, order = 'id DESC')
    @listings = Listing.paginate(:page => params[:page], 
                                 :per_page => per_page,
                                 :order => order,
                                 :select => 'id, created_at, author_id, title, status, times_viewed, category, good_thru', 
                                 :conditions => conditions)                                            
  end

  # Define how many listed items are shown per page.
  def per_page
    if params[:per_page].eql?("all")
      :all
    else  
      params[:per_page] || 10
    end
  end
  
  # Shows the profile page of the user. This method is used in peoplecontroller/show,
  # itemscontroller/edit and favorscontroller/edit.
  def show_profile
    @items = Item.find(:all, :conditions => "owner_id = '" + @person.id.to_s + "' AND status <> 'disabled'", :order => "title")
    @item = Item.new
    @favors = Favor.find(:all, :conditions => "owner_id = '" + @person.id.to_s + "' AND status <> 'disabled'", :order => "title")
    @favor = Favor.new
    if @person.id == @current_user.id
      save_navi_state(['own', 'profile', '', '', 'information'])
    else
      session[:profile_navi] = 'information'
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
  end
  
  def fetch_logged_in_user
    if session[:person_id]
      @current_user = Person.find_by_id(session[:person_id])
      s = Session.get_by_cookie(session[:cookie])
      if s.nil? || s.person_id != session[:person_id]
        # no matchin session in cos, so logout completely
        @current_user = session[:person_id] = session[:cookie] = nil
      end
    end
  end
  
  def logged_in
    return true if @current_user
    session[:return_to] = request.request_uri
    flash[:warning] = :you_must_login_to_do_this
    redirect_to new_session_path and return false
  end
  
  def is_admin
    return true if @current_user && @current_user.is_admin == 1
    flash[:warning] = :only_admin_users_are_allowed_to_do_this
    redirect_to :back
  end  
  
  def count_new_arrived_items
    if @current_user
      conditions = "person_id = '" + @current_user.id + "' AND is_read = 0"
      @inbox_new_count = PersonConversation.count(:all, :conditions => conditions)
      @comments_new_count = ListingComment.find_by_sql("SELECT listing_comments.id FROM listing_comments, listings WHERE listing_comments.listing_id = listings.id AND listings.author_id = '" + @current_user.id + "' AND listing_comments.author_id <> '" + @current_user.id + "' AND is_read = 0").size
      @requests_count = @current_user.get_friend_requests(session[:cookie])["entry"].size
      @new_arrived_items_count = @inbox_new_count + @comments_new_count + @requests_count
    end  
  end

  # Feedback form is present in every view.
  def set_up_feedback_form
    @feedback = Feedback.new
  end
  
  # Saves all collection ids to a session so that they can
  # be remembered when browsing the collection one by one.
  def save_message_collection_to_session(collection)
    session[:ids] = []
    session[:dates] = {}                             
    collection.each do |person_conversation|
      session[:ids] << person_conversation.id
      if session[:is_sent_mail]
        session[:dates][person_conversation.id] = person_conversation.last_sent_at
      else  
        session[:dates][person_conversation.id] = person_conversation.last_received_at
      end  
    end
  end
  
  # Creates a new Kassi event based on event type.
  def create_kassi_event(category = nil)
    @kassi_event = KassiEvent.new(params[:kassi_event])
    if @kassi_event.save
      @kassi_event.people << Person.find(params[:kassi_event][:realizer_id])
      @kassi_event.people << Person.find(params[:kassi_event][:receiver_id])
      if category && !["borrow_items", "favors"].include?(category)
        @kassi_event.realizer = nil
        @kassi_event.receiver = nil
        @kassi_event.save
      end
      @comment = PersonComment.new
      @comment.author = @current_user
      @comment.target_person_id = params[:kassi_event][:realizer_id]
      @comment.text_content = params[:kassi_event][:comment]
      @comment.kassi_event = @kassi_event
      unless @comment.text_content.eql?("") 
        @comment.save 
      end  
    end
  end
  
  def current_user?(person)
    if @current_user
      return @current_user.id == person.id
    end
    return false   
  end
  
end