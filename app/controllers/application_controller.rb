# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include Smerf
  include ApplicationHelper
  include CacheHelper
  include EventIdHelper
  include VisibilityHelper
  
  NEW_ARRIVED_ITEMS_CACHE_TIME = 20.seconds
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :only => [:create, :update, :destroy]  # :secret => '26c58c750ac36e1713e76184b3b8e162'

  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password

  before_filter :fetch_logged_in_user
  before_filter :set_locale
  before_filter :count_new_arrived_items
  before_filter :set_up_feedback_form
  before_filter :generate_event_id
  
  # after filter would be more logical, but then log would be skipped when action cache is hit.
  before_filter :log if LOG_TO_RESSI
  
  
  # Change current navigation state based on array containing new navi items.
  def save_navi_state(navi_items)
    session[:navi1] = navi_items[0] || session[:navi1]
    session[:navi2] = navi_items[1] || session[:navi2]
    session[:navi3] = navi_items[2] || session[:navi3]
    session[:navi4] = navi_items[3] || session[:navi4]
    session[:links_panel_navi] = navi_items[4] || session[:links_panel_navi]
  end

  # Sets navigation state to "nothing selected".
  def clear_navi_state
    session[:navi1] = session[:navi2] = session[:navi3] = session[:navi4] = session[:links_panel_navi] = nil
  end
  
  # Fetch listings based on conditions
  def fetch_listings(conditions, order = 'id DESC')
    @listings = Listing.paginate(:page => params[:page], 
                                 :per_page => per_page,
                                 :order => order,
                                 :select => 'id, created_at, author_id, title, status, times_viewed, category, good_thru, visibility', 
                                 :conditions => conditions)                                                                       
  end
  
  # Renders friend and group checkboxes for visibility
  def visibility_form_checkboxes
    @visibility = params[:visibility]
    if params[:object_type]
      case params[:object_type]
      when "Item"
        @object = Item.find(params[:object_id])
      when "Listing"
        @object = Listing.find(params[:object_id])
      when "Favor"
        @object = Favor.find(params[:object_id])   
      end
    end
    @groups = @object.groups if @object
    @object_visibility = params[:object_visibility]
    render :partial => "layouts/visibility_form_checkboxes"
  end

  # Define how many listed items are shown per page.
  def per_page
    if params[:per_page].eql?("all")
      :all
    else  
      params[:per_page] || 10
    end
  end

  # Sets locale file used.
  def set_locale
    if @current_user
      locale = @current_user.locale
      session[:locale] = @current_user.locale
      @current_user.update_attribute(:locale, params[:locale]) if params[:locale]
    else  
      locale = params[:locale] || session[:locale] || 'fi'
      session[:locale] = params[:locale] || session[:locale]
    end  
    I18n.locale = locale
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
    redirect_to root_path 
  end
  
  def is_admin?
    return true if @current_user && @current_user.is_admin == 1
    return false
  end  
  
  def count_new_arrived_items
    if @current_user
      # reading the cache is not in use untill we get proper expiration
      #@new_arrived_items_count, @inbox_new_count, @comments_new_count, @requests_count, @uncommented_kassi_events_count, @new_feedback_item_amount = Rails.cache.read("new_arrived_items_for:#{@current_user.id}")
      if @new_arrived_items_count.nil?
        conditions = ["person_id = ? AND is_read = 0", @current_user.id]
        @inbox_new_count = PersonConversation.count(:all, :conditions => conditions)
        @comments_new_count = ListingComment.count_by_sql(["SELECT COUNT(listing_comments.id) FROM listing_comments, listings WHERE listing_comments.listing_id = listings.id AND listings.author_id = ? AND listing_comments.author_id <> ? AND is_read = 0", @current_user.id, @current_user.id])
        ids = Array.new
        @current_user.get_friend_requests(session[:cookie])["entry"].each do |person|
          ids << person["id"]
        end
        @requests_count = Person.find_kassi_users_by_ids(ids).size
        @new_arrived_items_count = @inbox_new_count + @comments_new_count + @requests_count #uncommented kassi events is not in this sum!
        
        @uncommented_kassi_events_count = @current_user.uncommented_kassi_event_count
        if is_admin?
          @new_feedback_item_amount = Feedback.count(:all, :conditions => "is_handled = '0'")
        end  
        
        Rails.cache.write("new_arrived_items_for:#{@current_user.id}", [@new_arrived_items_count, @inbox_new_count,@comments_new_count, @requests_count, @uncommented_kassi_events_count, @new_feedback_item_amount], :expires_in => NEW_ARRIVED_ITEMS_CACHE_TIME)
      end
    end
  end

  # Feedback form is present in every view.
  def set_up_feedback_form
    @feedback = Feedback.new
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
  
  def must_be_current_user(person)
    unless current_user?(person)
      flash[:error] = :operation_not_permitted
      redirect_to home_person_path(@current_user)
      return false
    end
    return true
  end
  
  def must_not_be_current_user(person, error_message)
    if current_user?(person)
      flash[:warning] = error_message
      redirect_to home_person_path(@current_user)
      return false
    end
    return true
  end
  
  # this generates the event_id that will be used in 
  # requests to cos during this kassi-page view only
  def generate_event_id
    RestHelper.event_id = "#{EventIdHelper.generate_event_id(params)}_#{Time.now.to_f}"
    #puts "EVENT_ID IS NOW #{RestHelper.event_id}"
    
    # The event id is generated here and stored for the duration of this request.
    # The option above stores it to thread which should work fine on mongrel
    # The option below needs session to be available in models (around_filter :make_session_available_in_model)
    
    #session[:event_id] = "#{EventIdHelper.generate_event_id(params)}_#{Time.now.to_f}"
    #puts "EVENT_ID IS NOW #{session[:event_id]}"
    
  end
  
  protected  

  def log_error(exception) 
    super(exception)

    begin
      
      if RAILS_ENV == "production"
        sent_on = Time.now
        ErrorMailer.deliver_snapshot(
          exception, 
          clean_backtrace(exception), 
          session, #.instance_variable_get("@data"), 
          params.except(:password, :password2), 
          request,
          @current_user,
          sent_on)
          
        logger.info { "Error mail sent with time stamp: #{sent_on}" }
      end
    rescue => e
      logger.error(e)
    end
  end
  
  def log
    # puts "NOW LOGGING"
    # puts "ONGELMA? #{ params.inspect}"
    # p = params.clone
    # p["listing"].delete("image_file") if (p["listing"] && p["listing"]["image_file"])
    # puts "ONGELMA2 #{ p.inspect}"
    # puts "ONGELMA3 #{ filter_parameters(p)}"
    #  puts "ONGELMA4 #{ params.inspect}"
    CachedRessiEvent.create do |e|
      e.user_id           = @current_user ? @current_user.id : nil
      e.application_id    = "acm-TkziGr3z9Tab_ZvnhG"
      e.session_id        = request.session_options ? request.session_options[:id] : nil
      e.ip_address        = request.remote_ip
      e.action            = controller_class_name + "\#" + action_name
      begin
        if (params["listing"] && params["listing"]["image_file"])
          # This case breaks iomage upload (reason unknown) if we use to_json, so we'll have to skip it 
          e.parameters    = params.inspect.gsub('=>', ':')
        else  #normal case
          e.parameters    = filter_parameters(params).to_json
        end  
      rescue JSON::GeneratorError => error
        e.parameters      = ["There was error in genarating the JSON from the parameters."].to_json
        #puts e.parameters
      end
      
      
      e.return_value      = @_response.status
      e.semantic_event_id = RestHelper.event_id
      e.headers           = request.headers.reject do |*a|
        a[0].starts_with?("rack") or a[0].starts_with?("action_controller")
      end.to_json
    end
  end
  
end