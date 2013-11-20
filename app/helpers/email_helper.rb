# This is used in models that handle allowed_emails attribute to avoid duplicating same methods
module EmailHelper
  
  def email_allowed?(email)
    return true unless allowed_emails.present?
    
    allowed = false
    allowed_array = allowed_emails.split(",")
    allowed_array.each do |allowed_domain_or_address|
      allowed_domain_or_address.strip!
      allowed_domain_or_address.gsub!('.', '\.') #change . to be \. to only match a dot, not any char
      if email =~ /#{allowed_domain_or_address}$/
        allowed = true
        break
      end
    end
    return allowed
  end
  
  
  def can_accept_user_based_on_email?(person)
    person.emails.select{ |email| email.confirmed_at.present? }.find do |email|
      email_allowed?(email.address)
    end
  end
  
end