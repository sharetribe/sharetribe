# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include Smerf
  include ApplicationHelper
  
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

  # Returns visibility conditions for object_type (item, favor or listing)
  def get_visibility_conditions(object_type)
    conditions = " AND (visibility = 'everybody'"
    if @current_user
      case object_type
      when "listing"
        person_type = "author_id"
      when "item"
        person_type = "owner_id"
      when "favor"
        person_type = "owner_id"
      end
      conditions += " OR visibility = 'kassi_users' OR #{person_type} = '#{@current_user.id}'"
      friend_ids = @current_user.get_friend_ids(session[:cookie])
      if friend_ids.size > 0
        conditions += " OR (visibility IN ('friends', 'f_c', 'f_g', 'f_c_g') 
        AND #{person_type} IN (" + friend_ids.collect { |id| "'#{id}'" }.join(",") + "))"
      end
      if Person.count_by_sql(@current_user.contact_query("COUNT(id)")) > 0
        conditions += " OR (visibility IN ('contacts', 'f_c', 'c_g', 'f_c_g') 
        AND #{person_type} IN (#{@current_user.contact_query('id')}))"
      end
      if @current_user.groups(session[:cookie]).size > 0
        group_ids = @current_user.get_group_ids(session[:cookie]).collect { |id| "'#{id}'" }.join(",")
        conditions += " OR (visibility IN ('groups', 'f_g', 'c_g', 'f_c_g')
        AND id IN (
          SELECT #{object_type}s.id 
          FROM groups_#{object_type}s, #{object_type}s
          WHERE groups_#{object_type}s.group_id IN (#{group_ids})
          AND groups_#{object_type}s.#{object_type}_id = #{object_type}s.id
        ))"
      end
    end
    conditions += ")"
  end
  
  # Returns the visibility value to be saved in db based 
  # on the visibility parameter and checkbox values
  def get_visibility(object_type)
    # Use the method in ApplicationHelper
    set_visibility_in_params(object_type)
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
    locale = params[:locale] || session[:locale] || 'fi'
    I18n.locale = locale   
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
  
  def is_admin?
    return true if @current_user && @current_user.is_admin == 1
    return false
  end  
  
  def count_new_arrived_items
    if @current_user
      conditions = ["person_id = ? AND is_read = 0", @current_user.id]
      @inbox_new_count = PersonConversation.count(:all, :conditions => conditions)
      @comments_new_count = ListingComment.count_by_sql(["SELECT COUNT(listing_comments.id) FROM listing_comments, listings WHERE listing_comments.listing_id = listings.id AND listings.author_id = ? AND listing_comments.author_id <> ? AND is_read = 0", @current_user.id, @current_user.id])
      ids = Array.new
      @current_user.get_friend_requests(session[:cookie])["entry"].each do |person|
        ids << person["id"]
      end
      @requests_count = Person.find_kassi_users_by_ids(ids).size
      @new_arrived_items_count = @inbox_new_count + @comments_new_count + @requests_count
      if is_admin?
        @new_feedback_item_amount = Feedback.count(:all, :conditions => "is_handled = '0'")
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
  
end