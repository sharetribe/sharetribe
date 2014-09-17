class MessagesController < ApplicationController
  MessageEntity = MarketplaceService::Conversation::Entity::Message
  PersonEntity = MarketplaceService::Conversation::Entity::Person

  skip_filter :dashboard_only

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_send_a_message")
    controller.ensure_authorized t("layouts.notifications.you_are_not_authorized_to_do_this")
  end

  def create
    @message = Message.new(params[:message])
    if @message.save
      @message.conversation.send_email_to_participants(@current_community)
    else
      flash[:error] = "reply_cannot_be_empty"
    end

    # TODO This is somewhat copy-paste
    message = MessageEntity[@message].merge({mood: :neutral}).merge(sender: {
      id: @current_user.id,
      username: @current_user.username,
      name: @current_user.name,
      full_name: @current_user.full_name,
      avatar: @current_user.image.url(:thumb)
    })

    respond_to do |format|
      format.html { redirect_to single_conversation_path(:conversation_type => "received", :person_id => @current_user.id, :id => params[:message][:conversation_id]) }
      format.js { render :layout => false, locals: { message: message } }
    end
  end

end
