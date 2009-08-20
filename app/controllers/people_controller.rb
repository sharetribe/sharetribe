class PeopleController < ApplicationController

  before_filter :logged_in, :only  => [ :show, :edit, :update ]

  def index
    @title = "kassi_users"
    save_navi_state(['people', 'browse_people'])
    # @people = Person.find(:all).sort { 
    #   |a,b| a.name(session[:cookie]) <=> b.name(session[:cookie])
    # }.paginate :page => params[:page], :per_page => per_page
    @people = Person.paginate(:page => params[:page], :per_page => per_page)
  end
  
  def home
    save_navi_state(['home', ''])
    @events_per_page = 5
    @content_items_per_page = 5
    @kassi_events = KassiEvent.find(:all, :limit => @events_per_page, :order => "id DESC")
    @more_kassi_events_available = @events_per_page < KassiEvent.count(:all)
    get_newest_content_items(@content_items_per_page)
  end
  
  def more_kassi_events
    @events_per_page = params[:events_per_page].to_i + 5
    @kassi_events = KassiEvent.find(:all, :limit => @events_per_page, :order => "id DESC")
    @more_kassi_events_available = @events_per_page < KassiEvent.count(:all)
    render :update do |page|
      page["kassi_events"].replace_html :partial => "kassi_events/frontpage_event",
                                        :as => :kassi_event,
                                        :collection => @kassi_events, 
                                        :spacer_template => "layouts/dashed_line_white"
      page["more_kassi_events_link"].replace_html :partial => "more_kassi_events_link", 
                                                  :locals => { :events_per_page => @events_per_page }                                  
    end
  end
  
  def more_content_items
    @content_items_per_page = params[:content_items_per_page].to_i + 5
    logger.info "Content items per page: " + @content_items_per_page.to_s
    @content_items = get_newest_content_items(@content_items_per_page)
    render :update do |page|
      page["content_items"].replace_html :partial => "content_item",
                                        :as => :content_item,
                                        :collection => @content_items, 
                                        :spacer_template => "layouts/dashed_line"
      page["more_content_items_link"].replace_html :partial => "more_content_items_link", 
                                                   :locals => { :content_items_per_page => @content_items_per_page }                                  
    end
  end
  
  # Shows profile page of a person.
  def show
    @event_id = "show_profile_page_#{random_UUID}"
    @person = Person.find(params[:id])
    @items = @person.available_items(get_visibility_conditions("item"))
    @item = Item.new
    @favors = @person.available_favors(get_visibility_conditions("item"))
    @favor = Favor.new
    @groups = @person.groups(session[:cookie], @event_id)
    if @person.id == @current_user.id || session[:navi1] == nil || session[:navi1].eql?("")
      save_navi_state(['own', 'profile', '', '', 'information'])
    else
      save_navi_state(['people', 'browse_people'])
      session[:links_panel_navi] = 'information'
    end
  end
  
  def search
    save_navi_state(['people', 'search_people'])
    if params[:q]
      ids = Array.new
      Person.search(params[:q])["entry"].each do |person|
        ids << person["id"]
      end
      @people = Person.find_kassi_users_by_ids(ids).paginate :page => params[:page], :per_page => per_page
    end
  end

  # Creates a new person
  def create
    # should expire cache for people listing
    
    # Open a Session first only for Kassi to be able to create a user
    @session = Session.create
    session[:cookie] = @session.headers["Cookie"]
    
    # Try to create a new person in COS. 
    @person = Person.new
    if params[:person][:password].eql?(params[:person][:password2]) &&
       params[:person][:consent]
      begin
        @person = Person.create(params[:person], session[:cookie])
      rescue RestClient::RequestFailed => e
        @person.add_errors_from(e)
        preserve_create_form_values(@person)
        render :action => "new" and return
      end
      session[:person_id] = @person.id
      self.smerf_user_id = @person.id   
      @person.settings = Settings.create
      flash[:notice] = :registration_succeeded
      redirect_to home_person_path(@person) #TODO should redirect to the page where user was
    else
      @person.errors.add(:password, "does not match") unless params[:person][:password].eql?(params[:person][:password2])
      @person.errors.add(:consent, @person.errors.generate_message(:consent, :not_accepted)) unless params[:person][:consent]
      preserve_create_form_values(@person)
      render :action => "new" and return
    end
  end  
  
  # Displays register form
  def new
    clear_navi_state
    @person = Person.new
  end
  
  def edit
    @person = Person.find(params[:id])
    render :update do |page|
      page["profile_info_texts"].replace_html :partial => 'people/edit_profile_info'
      page["edit_profile_link"].replace_html :partial => 'cancel_edit_profile_link'
    end  
  end
  
  def update
    # should expire cache for people listing
    
    @person = Person.find(params[:id])
    @successful = update_person(@person)
    render :update do |page|
      if @successful
        page["profile_info_texts"].replace_html :partial => 'people/profile_info'
        page["edit_profile_link"].replace_html :partial => 'edit_profile_link'
        page["profile_header"].replace_html :partial => 'profile_header'
      end  
      refresh_announcements(page)
    end
  end
  
  def cancel_edit
    @person = Person.find(params[:id])
    render :update do |page|
      page["profile_info_texts"].replace_html :partial => 'people/profile_info'
      page["edit_profile_link"].replace_html :partial => 'edit_profile_link'
    end
  end
  
  def send_message
    @person = Person.find(params[:id])
    @message = Message.new
    return unless must_not_be_current_user(@person, :cant_send_message_to_self)
  end
  
  private
  
  def update_person(person)
    begin
      person.update_attributes(params[:person], session[:cookie])
      flash[:notice] = :person_updated_successfully
      flash[:error] = nil
    rescue RestClient::RequestFailed => e
      flash[:error] = translate_error_message(e.response.body.to_s)
      flash[:notice] = nil
      return false
    end
    return true
  end
  
  def translate_error_message(message)
    if message.include?("Given name is too long")
      return :given_name_is_too_long
    elsif message.include?("Family name is too long")
      return :family_name_is_too_long
    elsif message.include?("address is too long")
      return :street_address_is_too_long
    elsif message.include?("Postal code is too long") 
      return :postal_code_is_too_long  
    elsif message.include?("Locality is too long") 
      return :locality_is_too_long    
    elsif message.include?("Phone number is too long")
      return :phone_number_is_too_long 
    elsif message.include?("Description is too long")
      return :about_me_is_too_long
    else
      return message
    end  
  end
  
  private
  
  def get_newest_content_items(limit)
    favors = Favor.find(:all, 
                        :conditions => "status <> 'disabled'" + get_visibility_conditions("favor"),
                        :limit => limit,
                        :order => "id DESC")
    items =  Item.find(:all, 
                       :conditions => "status <> 'disabled'" + get_visibility_conditions("item"),
                       :limit => limit, 
                       :order => "id DESC")    
    listings = Listing.find(:all, 
                            :conditions => "status = 'open' AND good_thru >= '" + Date.today.to_s + "'" + get_visibility_conditions("listing"),
                            :limit => limit, 
                            :order => "id DESC")
    @content_items = favors.concat(items).concat(listings).sort {
      |a, b| b.created_at <=> a.created_at
    }                              
  end
  
  def preserve_create_form_values(person)
    person.form_username = params[:person][:username]
    person.form_given_name = params[:person][:given_name]
    person.form_family_name = params[:person][:family_name]
    person.form_password = params[:person][:password]
    person.form_password2 = params[:person][:password2]
    person.form_email = params[:person][:email]
  end
  
end
