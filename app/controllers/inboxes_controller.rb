class InboxesController < ApplicationController
  include MoneyRails::ActionViewExtension

  InboxRow = EntityUtils.define_builder(
    # General
    [:title, :string, :mandatory],
    [:last_update_at, :string, :mandatory],
    [:path, :string, :mandatory],
    [:other_party, :hash, :mandatory],
    [:is_read, :bool, :mandatory],

    # If listing
    [:listing_title, :string, :optional],
    [:listing_url, :string, :optional],

    # Only for transactions
    [:is_author, :bool, :optional],
    [:waiting_feedback_from_current, :optional],
    [:transaction_status, :string, :optional]
  )

  skip_filter :dashboard_only
  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_inbox")
  end

  def show
    params[:page] = 1 unless request.xhr?

    inbox_rows = MarketplaceService::Conversation::Query.conversations_and_transactions(
      @current_user.id,
      @current_community.id,
      {per_page: 15, page: params[:page]})
      .map { |conversation|
        inbox_row(conversation)
      }

    if request.xhr?
      # TODO Make sure these work
      render :partial => "additional_messages"
    else
      render :action => :show, locals: {
        inbox_rows: inbox_rows
      }
    end
  end

  def inbox_row(conversation)
    current_participation = conversation[:participants].find { |participant| participant[:person][:id] == @current_user.id }
    other_person = MarketplaceService::Conversation::Entity.other_by_id(conversation, @current_user.id)

    messages_and_actions = TransactionViewUtils.merge_messages_and_transitions(
      TransactionViewUtils.conversation_messages(conversation[:messages]),
      TransactionViewUtils.transition_messages(conversation[:transaction], conversation))

    conversation_opts = {
      title: messages_and_actions.last[:content],
      last_update_at: time_ago(messages_and_actions.last[:created_at]),
      is_read: current_participation[:is_read],
      other_party: person_entity_with_url(other_person),
      path: path_to_conversation_or_transaction(conversation)
    }

    listing_opts = if conversation[:listing]
      {
        listing_url: listing_path(id: conversation[:listing][:id]),
        listing_title: conversation[:listing][:title]
      }
    else
      {}
    end

    transaction_opts = if conversation[:transaction]
      {
        is_transaction_author: conversation[:transaction][:listing][:author_id] == @current_user.id,
        waiting_feedback_from_current: MarketplaceService::Transaction::Entity.waiting_testimonial_from?(conversation[:transaction], @current_user.id)
      }
    else
      {}
    end

    InboxRow[
      conversation_opts
        .merge(listing_opts)
        .merge(transaction_opts)
    ]
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
