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
    allowed = false
    
    #check primary email
    allowed = true if email_allowed?(person.email) && person.confirmed_at.present?
    
    #check additional confirmed emails
    person.emails.select{|e| e.confirmed_at.present?}.each do |e|
      allowed = true if email_allowed?(e.address)
    end
    
    return allowed
  end
  
end