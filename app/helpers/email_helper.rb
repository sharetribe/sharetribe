# This is used in models that handle allowed_emails attribute to avoid duplicating same methods
module EmailHelper

  def email_allowed?(email)
    EmailService.email_address_allowed?(email, allowed_emails)
  end

  def can_accept_user_based_on_email?(person)
    person.emails.select{ |email| email.confirmed_at.present? }.find do |email|
      email_allowed?(email.address)
    end
  end

end
