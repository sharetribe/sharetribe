class MessagesController < ApplicationController
  MessageEntity = MarketplaceService::Conversation::Entity::Message
  PersonEntity = MarketplaceService::Person::Entity

  skip_filter :dashboard_only

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_send_a_message")
  end

  before_filter do |controller|
    controller.ensure_authorized t("layouts.notifications.you_are_not_authorized_to_do_this")
  end

  def create
    @message = Message.new(params[:message])
    if @message.save
      Delayed::Job.enqueue(MessageSentJob.new(@message.id, @current_community.id))
    else
      flash[:error] = "reply_cannot_be_empty"
    end

    # TODO This is somewhat copy-paste
    message = MessageEntity[@message].merge({mood: :neutral}).merge(sender: PersonEntity.person(@current_user, @current_community.id))

    respond_to do |format|
      format.html { redirect_to single_conversation_path(:conversation_type => "received", :person_id => @current_user.id, :id => params[:message][:conversation_id]) }
      format.js { render :layout => false, locals: { message: message } }
    end
  end

end
