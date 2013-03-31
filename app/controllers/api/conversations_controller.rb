class Api::ConversationsController < Api::ApiController
  include ConversationsHelper
  
  before_filter :authenticate_person!
  before_filter :find_conversation, :except => [:index, :create]
  before_filter :only => :create do |controller|
    controller.ensure_authorized_to_view_listing(true)
  end
  before_filter :person_authorized_to_view_conversation, :except => [:index, :create]
  before_filter :ensure_listing_author_is_not_current_user, :only => :create
  
  def index
    @conversations = current_person.conversations.paginate(:per_page => @per_page, :page => @page)
  end
  
  def show
    respond_with @conversation
  end
  
  def create    
    @conversation = Conversation.new(params.slice("listing_id","status", "title").merge({
                                        "message_attributes" => {
                                            "content" => params["content"],
                                            "sender_id" => params["person_id"]},
                                        "conversation_participants" => {
                                            params["person_id"] => true,
                                            params["target_person_id"] => true
                                        } 
                                      }))
    # If related to listing, check that it's open and the user is authorized to view it
    if @listing
      if @listing.closed?
        response.status = 403
        render :json => ["Cannot reply to listing that is not open."] and return
      end
      unless @listing.visible_to?(@current_user, @current_community)
        response.status = 403
        render :json => ["Cannot reply to listing that should not be visible to current user."] and return
      end
    end
    
    if @conversation.title.nil?
      if @conversation.listing_id
        # set title automatically if not given
        @conversation.title = get_message_title(Listing.find(@conversation.listing_id))
      else 
        response.status = 404
        render :json => ["If no listing_id is given, title is obligatory parameter."] and return
      end
    end

    
    if @conversation.save
      response.status = 201
      Delayed::Job.enqueue(MessageSentJob.new(@conversation.messages.last.id, @current_community.id))
      respond_with @conversation
    else
      response.status = 400
      render :json => @conversation.errors.full_messages and return
    end
    
  end
  
  def update
    status = params["status"]
    if Conversation::VALID_STATUSES.include?(status) && @conversation.update_attributes(:status => status)
      if status == "accepted" || status == "rejected"
        @conversation.accept_or_reject(@current_user, @current_community, false)
      elsif status == "confirmed" || status == "canceled"
        @conversation.confirm_or_cancel(current_user, current_community, false)
      else
        raise "API conversation#update called with status that is not yet supported"
      end
      respond_with @conversation
    else
      response.status = 400
      render :json => ["The conversation status (#{status}) is not valid."] and return
    end
  end
  
  def new_message
    @message = Message.new(:content => params["content"], :sender_id => current_person.id, :conversation => @conversation)
    
    if @message.save 
      response.status = 201
      @message.conversation.send_email_to_participants(@current_community)
      respond_with @conversation
    else
       response.status = 400
       render :json => @message.errors.full_messages and return
    end  
    
    
  end
  
  def find_conversation
    @conversation = Conversation.find_by_id(params[:id])
    
    if @conversation.nil?
      response.status = 404
      render :json => ["No conversation found with given ID"] and return
    end
  end
  
  def person_authorized_to_view_conversation
    unless @conversation.participants.include?(@current_user)
      response.status = 403
      render :json => ["The logged in user is not part of this conversation."] and return
    end
  end
  
  def ensure_listing_author_is_not_current_user
    if (params["target_person_id"] && current_user?(Person.find_by_id(params["target_person_id"]))) || (!params["listing_id"] && listing = Listing.find_by_id(params["listing_id"])  && current_user?(listing.author))
      response.status = 400
      render :json => ["You cannot send message to yourself."] and return
    end
  end
end