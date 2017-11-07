class Admin::CommunityConversationsController < Admin::AdminBaseController
  ConversationQuery = MarketplaceService::Conversation::Query

  def index
    @selected_left_navi_link = "conversations"
    pagination_opts = PaginationViewUtils.parse_pagination_opts(params)

    conversations = ConversationQuery.conversations_for_community(
      @current_community.id,
      simple_sort_column(params[:sort]),
      sort_direction,
      pagination_opts[:limit],
      pagination_opts[:offset]
    )

    count = ConversationQuery.count_for_community(@current_community.id)

    conversations = conversations.map do |conversation|
      author = Maybe(conversation[:other_person]).or_else({is_deleted: true})
      starter = Maybe(conversation[:starter_person]).or_else({is_deleted: true})
      [author, starter].each { |p|
        p[:url] = person_path(p[:username]) unless p[:username].nil?
        p[:display_name] = PersonViewUtils.person_entity_display_name(p, "fullname")
      }
      conversation.merge({author: author, starter: starter})
    end

    conversations = WillPaginate::Collection.create(pagination_opts[:page], pagination_opts[:per_page], count) do |pager|
      pager.replace(conversations)
    end

    render "index", { locals: { community: @current_community, conversations: conversations } }
  end

  def show
    @selected_left_navi_link = "conversations"
    conversation_id = params[:id]
    conversation = Conversation.find(conversation_id)

    conversation = MarketplaceService::Conversation::Query.conversation_for_person(
      conversation_id,
      conversation.starter.id,
      @current_community.id)

    transaction = Transaction.find_by_conversation_id(conversation[:id])

    if transaction.present?
      redirect_to person_transaction_url(@current_user, {:id => transaction.id}) and return
    end

    author = Maybe(conversation[:other_person]).or_else({is_deleted: true})
    starter = Maybe(conversation[:starter_person]).or_else({is_deleted: true})
    [author, starter].each { |p|
      p[:url] = person_path(p[:username]) unless p[:username].nil?
      p[:display_name] = PersonViewUtils.person_entity_display_name(p, "fullname")
    }
    conversation = conversation.merge({author: author, starter: starter})

    messages = TransactionViewUtils.conversation_messages(conversation[:messages], @current_community.name_display_type)
    render locals: {
      messages: messages.reverse,
      conversation_data: conversation
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
    params[:direction] || "desc"
  end
end
