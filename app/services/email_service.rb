class EmailService

  # Give users `all_emails` and list of list of `allowed_emails` and the
  # `email` that will be removed. Return hash with true/false and a 
  # reason
  def self.can_delete_email(all_emails, allowed_emails, email)
    if all_emails.count < 2 then
      return {result: false, reason: :only_one}
    
    elsif EmailService.is_only_notification_email?(all_emails, email)
      return {result: false, reason: :only_notification}
    
    elsif EmailService.is_only_allowed_email?(all_emails, allowed_emails, email)
      return {result: false, reason: :only_allowed}
    
    else
      return {result: true}
    end
  end

  def self.is_only_allowed_email?(all_emails, list_of_allowed_emails, email)
    critical_email_ids = list_of_allowed_emails.collect do |allowed_emails|
      ok_emails = all_emails.select do |email|
        EmailService.email_allowed(email, allowed_emails)
      end

      if ok_emails.count == 1
        ok_emails.first.id
      end
    end

    critical_email_ids.include?(email.id)
  end

  def self.notification_emails(all_emails)
    all_emails.select { |email| email.send_notifications }
  end

  def self.is_only_notification_email?(all_emails, email)
    notification_emails = EmailService.notification_emails(all_emails)
    notification_emails.count == 1 && notification_emails.first.id == email.id
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
    EmailService.email_address_allowed?(email.address, allowed_emails)
  end

end