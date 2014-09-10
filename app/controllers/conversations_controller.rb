class ConversationsController < ApplicationController
  include MoneyRails::ActionViewExtension

  MessageForm = FormUtils.define_form("Message",
    :content,
    :conversation_id, # TODO Remove this
    :sender_id, # TODO Remove this
  ).with_validations {
    validates_presence_of :content, :conversation_id, :sender_id
  }


  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_inbox")
  end

  before_filter :only => [ :index, :received ] do |controller|
    controller.ensure_authorized t("layouts.notifications.you_are_not_authorized_to_view_this_content")
  end

  skip_filter :dashboard_only

  def index
    redirect_to received_person_messages_path(:person_id => @current_user.id)
  end

  def received
    params[:page] = 1 unless request.xhr?

    # conversation_models = @current_community.conversations.includes(:transaction).for_person(@current_user)
    #   .order("last_message_at DESC")
    #   .paginate(per_page: 15, page: params[:page])

    conversation_data = MarketplaceService::Conversation::Query.conversations_and_transactions(
      @current_user.id,
      @current_community.id,
      {per_page: 15, page: params[:page]})

    # conversation_data = conversation_models.map(&method(:map_conversation))

    conversation_data = conversation_data.map { |conversation|
      h = conversation.to_h

      current = conversation[:participants].select { |participant| participant.id == @current_user.id }.first
      other = conversation[:participants].reject { |participant| participant.id == @current_user.id }.first

      h[:other_party] = other.to_h.merge({url: person_path(id: other[:username])})
      h[:path] = single_conversation_path(:conversation_type => "received", :id => conversation.id)
      h[:read_by_current] = current.is_read
      h[:title] = MarketplaceService::Conversation::Entity.conversation_title(conversation)
      h[:last_update_at] = time_ago(MarketplaceService::Conversation::Entity.last_update_at(conversation))

      h[:listing_url] = if conversation.transaction
        listing_path(id: conversation.transaction.listing.id)
      end

      if conversation[:transaction]
        h[:is_transaction_author] = conversation[:transaction][:listing][:author_id] == @current_user.id
        h[:waiting_feedback_from_current] = MarketplaceService::Conversation::Entity.waiting_testimonial_from?(conversation[:transaction], @current_user.id)
      end

      h
    }

    if request.xhr?
      render :partial => "additional_messages"
    else
      render :action => :index, locals: {
        conversation_data: conversation_data
      }
    end
  end

  def show
    conversation_id = params[:id]
    conversation = @current_community.conversations.for_person(@current_user).find_by_id(conversation_id)

    if conversation.blank?
      flash[:error] = t("layouts.notifications.you_are_not_authorized_to_view_this_content")
      return redirect_to root
    end

    @current_user.read(conversation) unless conversation.read_by?(@current_user)

    message_form = MessageForm.new({sender_id: @current_user.id, conversation_id: conversation_id})

    render locals: {
      messages: conversation.messages.reverse,
      conversation_data: map_conversation(conversation),
      message_form: message_form,
      message_form_action: person_message_messages_path(@current_user, :message_id => conversation.id.to_s)
    }
  end

  def map_conversation(conversation)
    h = {}

    transaction = Maybe(conversation).transaction
    payment_sum = transaction.payment.total_sum.or_else { nil }

    last_message_content = if conversation.last_message.action == "pay"
      t("conversations.message.paid", :sum => humanized_money_with_symbol(payment_sum))
    elsif conversation.last_message.action.present?
      t("conversations.message.#{conversation.last_message.action}ed_#{transaction.discussion_type.get}").capitalize
    else
      conversation.last_message.content
    end

    # For some reason, other_party was wrapped inside "if". I guess there might be situations where other_party do
    # not exist. This is error in data. Anyway, we don't want the whole inbox to break because of this.
    h[:other_party] = Maybe(conversation).other_party(@current_user).map { |other_party|
      {
        name: other_party.name,
        avatar: other_party.image.url(:thumb),
        url: url_for(other_party)
      }
    }.or_else { nil }
    h[:read_by_current] = conversation.read_by?(@current_user)
    h[:last_message_sender_is_current_user] = conversation.last_message.sender == @current_user
    h[:last_message_content] = last_message_content
    h[:last_message_ago] = time_ago(conversation.last_message_at)
    h[:path_to_conversation] = single_conversation_path(:conversation_type => action_name, :id => conversation.id)


    h[:transaction] = transaction.map { |txn|
      listing = transaction.listing

      {
        model: txn, # TODO remove the reference to the model
        # TODO Move feedback from conversation participants to transaction
        waiting_feedback_from_current: false, # transaction.waiting_feedback_from?(@current_user).or_else { nil }
        is_author: txn.author == @current_user,
        status: txn.status,
        listing: listing.map { |l|
          {title: l.title, url: url_for(l) }
        }.or_else { nil },
        reply_to_listing_path: reply_to_listing_path(:listing_id => listing.id),
        action_button_label: listing.transaction_type.action_button_label(I18n.locale)
      }
    }.or_else { nil }

    h
  end
end
