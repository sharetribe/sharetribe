class Admin2::ConversationsService
  attr_reader :community, :params

  PER_PAGE = 100

  def initialize(community:, params:)
    @params = params
    @community = community
  end

  def conversations
    @conversations ||= filtered_scope
      .order("#{simple_sort_column(params[:sort])} #{sort_direction}")
      .paginate(page: params[:page], per_page: params[:per_page] || PER_PAGE)
  end

  def conversation
    @conversation ||= resource_scope.find(params[:id])
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

  def filter?
    params[:q].present?
  end

  private

  def resource_scope
    Conversation.non_payment_or_free(community)
  end

  def filtered_scope
    scope = resource_scope
    if params[:q].present?
      query_ids = Conversation.by_keyword(community, "%#{params[:q]}%")
      scope = scope.where(id: query_ids)
    end
    scope
  end

  def simple_sort_column(sort_column)
    case sort_column
    when 'last_activity'
      'last_message_at'
    when "started"
      'created_at'
    else
      'created_at'
    end
  end

  def sort_direction
    if params[:direction] == 'asc'
      'asc'
    else
      'desc'
    end
  end

end
