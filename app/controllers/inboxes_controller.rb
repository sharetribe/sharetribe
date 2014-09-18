class InboxesController < ApplicationController
  include MoneyRails::ActionViewExtension

  conversation_fields = [
    [:title, :string, :mandatory],
    [:last_update_at, :string, :mandatory],
    [:path, :string, :mandatory],
    [:other_party, :hash, :mandatory],
    [:is_read, :bool, :mandatory]
  ]

  transasction_fields = [
    [:listing_title, :string, :mandatory],
    [:listing_url, :string, :mandatory],
    [:is_author, :bool, :mandatory],
    [:waiting_feedback_from_current, :mandatory],
    [:transaction_status, :string, :mandatory]
  ]

  InboxRowConversation = EntityUtils.define_builder(*conversation_fields)
  InboxRowTransaction = EntityUtils.define_builder(*conversation_fields, *transasction_fields)

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
      }.compact

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

    if other_person.blank?
      # For some reason, the whole .haml content was wrapped in if, which made sure the other_party is present.
      # I guess the reason is that there were some broken data in DB, transactions which didn't have the other-party,
      # and to ensure it doesn't break the whole inbox, the if-clause was added.
      #
      # If that's the case, consider cleaning the DB and removing this line.
      return nil
    end

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

    if conversation[:transaction]
      InboxRowTransaction[{
        listing_url: listing_path(id: conversation[:transaction][:id]),
        listing_title: conversation[:transaction][:listing][:title],
        is_author: conversation[:transaction][:listing][:author_id] == @current_user.id,
        waiting_feedback_from_current: MarketplaceService::Transaction::Entity.waiting_testimonial_from?(conversation[:transaction], @current_user.id),
        transaction_status: conversation[:transaction][:status]
      }.merge(conversation_opts)]
    else
      InboxRowConversation[conversastion_opts]
    end
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
