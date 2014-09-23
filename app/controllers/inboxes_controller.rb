class InboxesController < ApplicationController
  include MoneyRails::ActionViewExtension

  # conversation_fields = [
  #   [:path, :string, :mandatory]
  # ]

  # transasction_fields = [
  #   [:listing_url, :string, :mandatory]
  # ]

  # InboxRowConversationWithUrl = EntityUtils.define_builder(*conversation_fields)
  # InboxRowTransactionWithUrl = EntityUtils.define_builder(*conversation_fields, *transasction_fields)

  skip_filter :dashboard_only
  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_inbox")
  end

  def show
    # We use pageless scroll, so the page should be always the first one (1) when request was not AJAX request
    params[:page] = 1 unless request.xhr?

    pagination_opts = PaginationViewUtils.parse_pagination_opts(params)

    inbox_rows = MarketplaceService::Conversation::Query.inbox_data(
      @current_user.id,
      @current_community.id,
      pagination_opts[:limit],
      pagination_opts[:offset])
      .map { |inbox_row_data|
        map_urls(inbox_row_data)
      }.compact

    # count = MarketplaceService::Conversation::Query.inbox_data_count(@current_user.id, @current_community.id)
    count = 999

    paginated_inbox_rows = WillPaginate::Collection.create(pagination_opts[:page], pagination_opts[:per_page], count) do |pager|
      pager.replace(inbox_rows)
    end

    if request.xhr?
      render :partial => "inbox_row",
        :collection => paginated_inbox_rows, :as => :conversation,
        locals: {
          payments_in_use: @current_community.payments_in_use?
        }
    else
      render locals: {
        inbox_rows: paginated_inbox_rows,
        payments_in_use: @current_community.payments_in_use?
      }
    end
  end

  def map_urls(conversation)
    # current_participation = conversation[:participants].find { |participant| participant[:person][:id] == @current_user.id }
    # other_person = MarketplaceService::Conversation::Entity.other_by_id(conversation, @current_user.id)

    # if other_person.blank?
    #   # For some reason, the whole .haml content was wrapped in if, which made sure the other_party is present.
    #   # I guess the reason is that there were some broken data in DB, transactions which didn't have the other-party,
    #   # and to ensure it doesn't break the whole inbox, the if-clause was added.
    #   #
    #   # If that's the case, consider cleaning the DB and removing this line.
    #   return nil
    # end

    # messages_and_actions = TransactionViewUtils.merge_messages_and_transitions(
    #   TransactionViewUtils.conversation_messages(conversation[:messages]),
    #   TransactionViewUtils.transition_messages(conversation[:transaction], conversation))

    # conversation_opts = {
    #   title: messages_and_actions.last[:content],
    #   last_update_at: time_ago(messages_and_actions.last[:created_at]),
    #   is_read: current_participation[:is_read],
    #   other_party: person_entity_with_url(other_person),
    #   path: path_to_conversation_or_transaction(conversation)
    # }

    # if conversation[:transaction]
    #   is_read = if MarketplaceService::Transaction::Entity.should_notify?(conversation[:transaction], @current_user.id)
    #     false
    #   else
    #     conversation_opts[:is_read]
    #   end

    #   InboxRowTransaction[conversation_opts.merge({
    #     listing_url: listing_path(id: conversation[:transaction][:id]),
    #     listing_title: conversation[:transaction][:listing][:title],
    #     is_author: conversation[:transaction][:listing][:author_id] == @current_user.id,
    #     waiting_feedback_from_current: MarketplaceService::Transaction::Entity.waiting_testimonial_from?(conversation[:transaction], @current_user.id),
    #     transaction_status: conversation[:transaction][:status],
    #     is_read: is_read
    #   })]
    # else
    #   InboxRowConversation[conversation_opts]
    # end

    # Add URLs here
    conversation
  end

  def path_to_conversation_or_transaction(conversation)
    if conversation[:transaction].present?
      person_transaction_path(:person_id => @current_user.username, :id => conversation[:transaction][:id])
    else
      single_conversation_path(:conversation_type => "received", :id => conversation[:id])
    end
  end

  def person_entity_with_url(person_entity)
    person_entity.merge({url: person_path(id: person_entity[:username])})
  end
end
