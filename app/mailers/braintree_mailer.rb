class BraintreeMailer < ActionMailer::Base
  default :from => APP_CONFIG.sharetribe_mail_from_address
  layout 'email'

  add_template_helper(EmailTemplateHelper)

  def notify_merchant_active_account(person)
    @person = person
    mail(:to => @person.emails.first.address,
         :subject => "Bank Details Approved")
  end

  def notify_successfull_purchase(person)
    @person = person
    mail(:to => @person.emails.first.address,
         :subject => "Thank you for purchasing")
  end
end
