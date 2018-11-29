class Admin::ConversationsService
  attr_reader :community, :params

  PER_PAGE = 30

  def initialize(community:, params:)
    @params = params
    @community = community
  end

  def conversations
    @conversations ||= Conversation.free_for_community(
      community,
      simple_sort_column(params[:sort]),
      sort_direction)
      .paginate(page: params[:page], per_page: params[:per_page] || PER_PAGE)
  end

  def conversation
    @conversation ||= Conversation.find(params[:id])
  end

  def conversation_messages
    @conversation_messages ||= TransactionViewUtils.conversation_messages(conversation.messages.latest, community.name_display_type)
  end

  def conversation_transaction
    @conversation_transaction ||= conversation.tx
  end

  def conversation_transaction?
    conversation_transaction.present?
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
