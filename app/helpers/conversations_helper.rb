module ConversationsHelper

  def get_message_title(listing)
    listing.title
  end

  def icon_for(status)
    case status
    when "accepted"
      "ss-check"
    when "confirmed"
      "ss-check"
    when "rejected"
      "ss-delete"
    when "canceled"
      "ss-delete"
    when "paid"
      "ss-check"
    end
  end

  def path_for_status_link(status, conversation, current_user)
    case status
    when "accept"
      accept_person_message_path(:person_id => current_user.id, :id => conversation.id.to_s)
    when "confirm"
      confirm_person_message_path(:person_id => current_user.id, :id => conversation.id.to_s)
    when "reject"
      reject_person_message_path(:person_id => @current_user.id, :id => conversation.id.to_s)
    when "cancel"
      cancel_person_message_path(:person_id => current_user.id, :id => conversation.id.to_s)
    end
  end

  def free_conversation?
    params[:message_type] || (@listing && @listing.transaction_type.is_inquiry?)
  end
end
