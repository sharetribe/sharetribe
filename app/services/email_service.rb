class EmailService

  class << self

    # Give list of `emails` and get back a list of email where the mail
    # should be sent to
    def emails_to_send_message(emails)
      send_to = confirmed_notification_emails(emails)

      unless send_to.empty?
        send_to
      else
        confirmed_emails(emails).take(1)
      end
    end

    # Give list of `emails` and get back a comma-separated string representation
    # which can be set as SMTP to address
    def emails_to_smtp_addresses(emails)
      emails.collect(&:address).join(", ")
    end
  end

  # Give user's `all_emails` and list of list of `allowed_emails` and the
  # `email` that will be removed. Return hash with true/false and a
  # reason
  def self.can_delete_email(all_emails, email, allowed_emails=[])
    if all_emails.count < 2 then
      return {result: false, reason: :only_one}

    elsif self.is_only_confirmed?(all_emails, email)
      return {result: false, reason: :only_confirmed}

    elsif self.is_only_notification_email?(all_emails, email)
      return {result: false, reason: :only_notification}

    elsif self.is_only_allowed_email?(all_emails, allowed_emails, email)
      return {result: false, reason: :only_allowed}

    else
      return {result: true}
    end
  end

  def self.is_only_confirmed?(all_emails, email)
    email.confirmed_at && self.confirmed_emails(all_emails).count == 1
  end

  def self.is_only_allowed_email?(all_emails, list_of_allowed_emails, email)
    critical_email_ids = list_of_allowed_emails.collect do |allowed_emails|
      ok_emails = all_emails.select do |email|
        self.email_allowed(email, allowed_emails)
      end

      # Can be critical for two reasons:
      # - Only email passing the email restriction
      # - Only CONFIRMED email passing the email restriction
      critical_email_id = if ok_emails.count == 1
        ok_emails.first.id
      else
        confirmed_ok_emails = ok_emails.select { |ok_email| ok_email.confirmed_at }
        if confirmed_ok_emails.count == 1
          ok_emails.first.id
        end
      end

      # Return the id or nil
      critical_email_id
    end

    critical_email_ids.include?(email.id)
  end

  def self.notification_emails(all_emails)
    all_emails.select { |email| email.send_notifications }
  end

  def self.notification_emails(all_emails)
    all_emails.select { |email| email.send_notifications }
  end

  def self.confirmed_emails(all_emails)
    all_emails.select { |email| email.confirmed_at }
  end

  def self.confirmed_notification_emails(all_emails)
    self.confirmed_emails(all_emails).select { |email| email.send_notifications }
  end

  def self.is_only_notification_email?(all_emails, email)
    notification_emails = self.notification_emails(all_emails)
    confirmed_notification_emails = self.confirmed_notification_emails(all_emails)

    # True if
    # - email is the only notification email
    # - email is the only CONFIRMED notification email
    notification_emails.collect(&:id) == [email.id] || confirmed_notification_emails.collect(&:id) == [email.id]
  end

  def self.email_address_allowed?(address, allowed_emails)
    return true unless allowed_emails.present?

    allowed = false
    allowed_array = allowed_emails.split(",")
    allowed_array.each do |allowed_domain_or_address|
      allowed_domain_or_address.strip!
      allowed_domain_or_address.gsub!('.', '\.') #change . to be \. to only match a dot, not any char
      if address =~ /#{allowed_domain_or_address}$/
        allowed = true
        break
      end
    end
    return allowed
  end

  def self.email_allowed(email, allowed_emails)
    self.email_address_allowed?(email.address, allowed_emails)
  end

end
