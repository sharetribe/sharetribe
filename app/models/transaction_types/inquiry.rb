class Inquiry < TransactionType

  DEFAULTS = {}

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

end
