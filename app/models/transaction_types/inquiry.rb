class Inquiry < TransactionType

  def direction
    "inquiry"
  end

  def is_offer?
    false
  end

  def is_request?
    false
  end

  def is_inquiry?
    true
  end

  def api_name
    "free_conversation"
  end

end
