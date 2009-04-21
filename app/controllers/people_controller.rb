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
    if @current_user
      if params[:id] && !params[:id].eql?(@current_user.id)
        redirect_to listings_path
      else
        save_navi_state(['own', 'home'])
        @listings = Listing.find(:all, 
                                 :limit => 2, 
                                 :conditions => "status = 'open' AND good_thru >= '" + Date.today.to_s + "'" + get_visibility_conditions("listing"),
                                 :order => "id DESC")                         
        @person_conversations = []                         
        person_conversations = PersonConversation.find(:all,
                                                       :conditions => "person_id = '" + @current_user.id + "'",
                                                       :order => "last_received_at DESC") 
        person_conversations.each do |person_conversation|
          conversation_ok = false
          person_conversation.conversation.messages.each do |message|
            conversation_ok = true unless message.sender == @current_user      
          end
          @person_conversations << person_conversation if conversation_ok  
          @comments = ListingComment.find_by_sql("SELECT listing_comments.id, listing_comments.is_read, listing_comments.created_at, listing_comments.content, listing_comments.listing_id, listings.title, listing_comments.author_id FROM listing_comments, listings WHERE listing_comments.listing_id = listings.id AND listings.author_id = '" + @current_user.id + "' AND listing_comments.author_id <> '" + @current_user.id + "' ORDER BY listing_comments.created_at desc LIMIT 2")
        end
        session[:is_sent_mail] = false
        save_message_collection_to_session(@person_conversations)                                               
      end  
    else
      redirect_to listings_path
    end    
  end
  
  # Shows profile page of a person.
  def show
    @person = Person.find(params[:id])
    @items = @person.available_items(get_visibility_conditions("item"))
    @item = Item.new
    @favors = @person.available_favors(get_visibility_conditions("item"))
    @favor = Favor.new
    Group.add_new_public_groups_to_kassi_db(session[:cookie])
    @groups = @person.groups(session[:cookie])
    if @person.id == @current_user.id || session[:navi1] == nil || session[:navi1].eql?("")
      save_navi_state(['own', 'profile', '', '', 'information'])
    else
      save_navi_state(['people', 'browse_people'])
      session[:profile_navi] = 'information'
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

  def create
    # Open a Session first only for Kassi to be able to create a user
    @session = Session.create
    session[:cookie] = @session.headers["Cookie"]
    @person = Person.new
    if params[:person][:password].eql?(params[:person][:password2])
      begin
        @person = Person.create(params[:person], session[:cookie])
      rescue ActiveResource::BadRequest => e
        handle_person_errors(@person, e)
        render :action => "new" and return
      end  
      session[:person_id] = @person.id
      @person.settings = Settings.create
      redirect_to(root_path) #TODO should redirect to the page where user was
    else
      @person.errors.add(:password, "does not match")
      handle_person_errors(@person)
      render :action => "new" and return
    end
  end  
  
  def new
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
    rescue ActiveResource::BadRequest => e
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
    else
      return message
      #return :user_data_could_not_be_saved_due_to_unknown_error 
    end  
  end
  
  def handle_person_errors(person, exception=nil)
    if exception
      error_array = exception.response.body[2..-3].split('","').each do |error|
        error = error.split(" ", 2)
        person.errors.add(error[0].downcase, error[1]) 
      end
    end
    person.form_username = params[:person][:username]
    person.form_password = params[:person][:password]
    person.form_password2 = params[:person][:password2]
    person.form_email = params[:person][:email]
  end
  
end
