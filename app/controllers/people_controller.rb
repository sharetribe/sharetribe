class PeopleController < ApplicationController

  before_filter :logged_in, :only  => [ :show ]

  def index
    save_navi_state(['people', 'browse_people'])
    @pagination_type = "people"
    @people = Person.find(:all).sort { 
      |a,b| a.name(session[:cookie]) <=> b.name(session[:cookie])
    }.paginate :page => params[:page], :per_page => per_page
  end
  
  def home
    if @current_user
      if params[:id] && !params[:id].eql?(@current_user.id)
        redirect_to listings_path
      else
        save_navi_state(['own', 'home'])
        @listings = Listing.find(:all, 
                                 :limit => 2, 
                                 :conditions => "status = 'open' AND good_thru >= '" + Date.today.to_s + "'",
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
    show_profile
  end
  
  def search
    save_navi_state(['people', 'search_people'])
  end

  def create
    # Open a Session first only for Kassi to be able to create a user
    @session = Session.create
    session[:cookie] = @session.headers["Cookie"]
    
    begin
      @person = Person.create(params[:person], session[:cookie])
    rescue ActiveResource::BadRequest => e
      flash[:error] = e.response.body
      redirect_to new_person_path and return
    end
    session[:person_id] = @person.id
    redirect_to(root_path) #TODO should redirect to the page where user was
  end
  
  def new
    if RAILS_ENV == "production"
      render :template => "people/beta"
    end
    @person = Person.new
  end
  
  def send_message
    @person = Person.find(params[:id])
    @message = Message.new
  end
  
end
