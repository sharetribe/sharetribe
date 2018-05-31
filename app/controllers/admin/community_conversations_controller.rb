class Admin::CommunityConversationsController < Admin::AdminBaseController
  def index
    @selected_left_navi_link = "conversations"
    pagination_opts = PaginationViewUtils.parse_pagination_opts(params)

    conversations = Conversation.free_for_community(
      @current_community,
      simple_sort_column(params[:sort]),
      sort_direction)
      .paginate(page: pagination_opts[:page], per_page: pagination_opts[:per_page])
    render "index", { locals: { community: @current_community, conversations: conversations } }
  end

  def show
    @selected_left_navi_link = "conversations"
    conversation = Conversation.find(params[:id])
    transaction = conversation.tx

    if transaction.present?
      redirect_to person_transaction_url(@current_user, {:id => transaction.id}) and return
    end

    messages = TransactionViewUtils.conversation_messages(conversation.messages.latest, @current_community.name_display_type)
    render locals: {
      messages: messages,
      conversation: conversation
    }
  end

  private

  def simple_sort_column(sort_column)
    case sort_column
    when "last_activity"
      "last_message_at"
    when "started"
      "created_at"
    else
      "created_at"
    end
  end

  def sort_direction
    if params[:direction] == "asc"
      "asc"
    else
      "desc" #default
    end
  end
end
