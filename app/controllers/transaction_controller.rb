class TransactionController < ApplicationController

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_inbox")
  end

  before_filter :only => [ :index, :received ] do |controller|
    controller.ensure_authorized t("layouts.notifications.you_are_not_authorized_to_view_this_content")
  end

  skip_filter :dashboard_only

  # def index
  #   redirect_to received_person_messages_path(:person_id => @current_user.id)
  # end

  def show
    transaction = @current_community.transactions.for_person(@current_user).find_by_id(params[:id])

    if @transaction.blank?
      flash[:error] = t("layouts.notifications.you_are_not_authorized_to_view_this_content")
      redirect_to root and return
    end

    conversation = transaction.conversation

    @current_user.read(conversation) unless conversation.read_by?(@current_user)
    @other_party = conversation.other_party(@current_user)

    messages = conversation.messages.reverse.map do |message|
      message_hash = {
        type: message.action.present? ? "action" : "message",
      }

      message_hash[:content] = if message.action.blank?
        message.content
      else
        if message.action.eql?("pay")
          t(".paid", :sum => sum_with_currency(message.conversation.transaction.payment.total_sum, message.conversation.transaction.payment.currency))
        else
          # TODO CONTINUE HERE!
        end
      end
    end

    render locals: { messages: @conversation.messages.reverse }
  end
end
