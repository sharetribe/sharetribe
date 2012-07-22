class Api::ConversationsController < Api::ApiController
  include ConversationsHelper
  
  before_filter :authenticate_person!
  
  # TODO add same filters as in the normal conversations controller
  
  def index
    @page = params["page"] || 1
    @per_page = params["per_page"] || 50
    @conversations = current_person.conversations.paginate(:per_page => @per_page, :page => @page)
  end
  
  def show
    @page = params["page"] || 1
    @per_page = params["per_page"] || 50
    @conversation = Conversation.find_by_id(params[:id])
    
    if @conversation.nil?
      response.status = 404
      render :json => ["No conversation found with given ID"] and return
    end
    respond_with @conversation
  end
  
  def create
    @current_community = Community.find_by_id(params[:community_id])
    if @current_community.nil? 
      response.status = 404
      render :json => ["No community found with given id"] and return
    end
    
    @conversation = Conversation.new(params.slice("listing_id","status", "title").merge({
                                        "message_attributes" => {
                                            "content" => params["content"],
                                            "sender_id" => params["person_id"]},
                                        "conversation_participants" => {
                                            params["person_id"] => true,
                                            params["target_person_id"] => true
                                        } 
                                      }))
    
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
      Delayed::Job.enqueue(MessageSentJob.new(@conversation.id, @conversation.messages.last.id, @current_community.full_domain))
      respond_with @conversation
    else
      response.status = 400
      render :json => @conversation.errors.full_messages and return
    end
    
  end
  
end