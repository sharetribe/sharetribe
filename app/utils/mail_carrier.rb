module MailCarrier

  module_function

  # This is just a placeholder. Delivering later
  # hasn't been implemented you.
  def deliver_later(message)
    deliver_now(message)
  end

  def deliver_now(message)
    message.deliver_now
  end

end
