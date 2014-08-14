module ConversationsHelper

  def free_conversation?
    params[:message_type] || (@listing && @listing.transaction_type.is_inquiry?)
  end
end
