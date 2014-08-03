class PersonMessagesController < ApplicationController

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_send_a_message")
  end

  before_filter :fetch_recipient
  skip_filter :dashboard_only

  def new
    @conversation = Conversation.new
  end

  def create
    @conversation = new_conversation
    if @conversation.save
      flash[:notice] = t("layouts.notifications.message_sent")
      Delayed::Job.enqueue(MessageSentJob.new(@conversation.messages.last.id, @current_community.id))
      redirect_to @recipient
    else
      flash[:error] = "Sending the message failed. Please try again."
      redirect_to root
    end
  end

  private

  def new_conversation
    conversation = Conversation.new(params[:conversation].merge(community: @current_community))
    conversation.build_starter_participation(@current_user)
    conversation.build_participation(@recipient)
    conversation
  end

  def fetch_recipient
    @recipient = Person.find(params[:person_id])
  end
end
