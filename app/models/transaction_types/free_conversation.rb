class FreeConversation < TransactionType

  def direction
    "none"
  end

  def is_offer?
    false
  end

  def is_request?
    false
  end

  def api_name
    "free_conversation"
  end

end