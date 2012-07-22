class Api::ConversationsController < Api::ApiController
  
  before_filter :authenticate_person!
  
  # TODO add same filters as in the normal conversations controller
  
  def index
    @page = params["page"] || 1
    @per_page = params["per_page"] || 50
    @conversations = current_person.conversations.paginate(:per_page => @per_page, :page => @page)
  end
  
end