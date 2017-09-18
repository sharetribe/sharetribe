class PersonMessagesController < ApplicationController

  before_action do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_send_a_message")
  end

  before_action :fetch_recipient

  def new
    @conversation = Conversation.new
  end

  def create
    validate(params).and_then { |params|
      save_conversation(params)
    }.on_success { |conversation|
      flash[:notice] = t("layouts.notifications.message_sent")
      Delayed::Job.enqueue(MessageSentJob.new(conversation.messages.last.id, @current_community.id))
      redirect_to @recipient
    }.on_error {
      flash[:error] = t("layouts.notifications.message_not_sent")
      redirect_to search_path
    }
  end

  private

  def validate(params)
    content_present = Maybe(params)[:conversation][:message_attributes][:content]
                      .map(&:present?)
                      .or_else(false)

    if content_present
      Result::Success.new(params)
    else
      Result::Error.new("Message content was empty")
    end
  end

  def save_conversation(params)
    conversation = new_conversation(params)
    if conversation.save
      Result::Success.new(conversation)
    else
      Result::Error.new("Message saving failed")
    end
  end

  def new_conversation(params)
    conversation_params = params.require(:conversation).permit(
      message_attributes: :content
    )
    conversation_params[:starting_page] = ::Conversation::PROFILE
    conversation_params[:message_attributes][:sender_id] = @current_user.id

    conversation = Conversation.new(conversation_params.merge(community: @current_community))
    conversation.build_starter_participation(@current_user)
    conversation.build_participation(@recipient)
    conversation
  end

  def fetch_recipient
    username = params[:person_id]
    @recipient = Person.find_by!(username: username, community_id: @current_community.id)
    if @current_user == @recipient
      flash[:error] = t("layouts.notifications.you_cannot_send_message_to_yourself")
      redirect_to search_path
    end
  end
end
