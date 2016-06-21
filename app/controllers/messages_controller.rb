class MessagesController < ApplicationController
  MessageEntity = MarketplaceService::Conversation::Entity::Message
  PersonEntity = MarketplaceService::Person::Entity

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_send_a_message")
  end

  before_filter EnsureCanAccessPerson.new(:person_id, error_message_key: "layouts.notifications.you_are_not_authorized_to_do_this")

  def create
    unless is_participant?(@current_user, params[:message][:conversation_id])
      flash[:error] = t("layouts.notifications.you_are_not_authorized_to_do_this")
      return redirect_to search_path
    end

    message_params = params.require(:message).permit(
      :conversation_id,
      :content
    ).merge(
      sender_id: @current_user.id
    )

    @message = Message.new(message_params)
    if @message.save
      Delayed::Job.enqueue(MessageSentJob.new(@message.id, @current_community.id))
    else
      flash[:error] = "reply_cannot_be_empty"
    end

    # TODO This is somewhat copy-paste
    message = MessageEntity[@message].merge({mood: :neutral}).merge(sender: person_entity_with_display_name(PersonEntity.person(@current_user, @current_community.id)))

    respond_to do |format|
      format.html { redirect_to single_conversation_path(:conversation_type => "received", :person_id => @current_user.id, :id => params[:message][:conversation_id]) }
      format.js { render :layout => false, locals: { message: message } }
    end
  end

  private

  def person_entity_with_display_name(person_entity)
    person_display_entity = person_entity.merge(
      display_name: PersonViewUtils.person_entity_display_name(person_entity, @current_community.name_display_type)
    )
  end

  def is_participant?(person, conversation_id)
    Conversation.find(conversation_id).participant?(person)
  end

end
