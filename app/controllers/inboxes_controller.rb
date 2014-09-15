class InboxesController < ApplicationController
  include MoneyRails::ActionViewExtension

  skip_filter :dashboard_only
  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_inbox")
  end

  def show
    params[:page] = 1 unless request.xhr?

    conversation_data = MarketplaceService::Conversation::Query.conversations_and_transactions(
      @current_user.id,
      @current_community.id,
      {per_page: 15, page: params[:page]})

    conversation_data = conversation_data.map { |conversation|
      h = conversation.to_h

      current = conversation[:participants].select { |participant| participant[:id] == @current_user.id }.first
      other = conversation[:participants].reject { |participant| participant[:id] == @current_user.id }.first

      h[:other_party] = other.to_h.merge({url: person_path(id: other[:username])})

      h[:path] = if h[:transaction].present?
        person_transaction_path(:person_id => @current_user.username, :id => h[:transaction][:id])
      else
        single_conversation_path(:conversation_type => "received", :id => conversation[:id])
      end

      h[:read_by_current] = current[:is_read]

      transaction = if h[:transaction].present?
        transaction = h[:transaction].to_h
        author_id = transaction[:listing][:author_id]
        starter_id = transaction[:starter_id]

        author = h[:participants].find { |participant| participant[:id] == author_id }
        starter = h[:participants].find { |participant| participant[:id] == starter_id }

        author_url = {url: person_path(id: author[:username])}
        starter_url = {url: person_path(id: starter[:username])}

        transaction.merge({author: author, starter: starter})
      else
        {}
      end

      messages = TransactionViewUtils::merge_messages_and_transitions(h[:messages], TransactionViewUtils::create_messages_from_actions(transaction || {}))

      h[:title] = messages.last[:content]
      h[:last_update_at] = time_ago(messages.last[:created_at])

      h[:listing_url] = if conversation[:transaction]
        listing_path(id: conversation[:transaction][:listing][:id])
      end

      if conversation[:transaction]
        h[:is_transaction_author] = conversation[:transaction][:listing][:author_id] == @current_user.id
        h[:waiting_feedback_from_current] = MarketplaceService::Transaction::Entity.waiting_testimonial_from?(conversation[:transaction], @current_user.id)
      end

      h
    }

    if request.xhr?
      # TODO Make sure these work
      render :partial => "additional_messages"
    else
      render :action => :show, locals: {
        conversation_data: conversation_data
      }
    end
  end

end
