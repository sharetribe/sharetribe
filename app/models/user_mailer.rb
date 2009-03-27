class UserMailer < ActionMailer::Base

  def notification_of_new_message(recipient, message)
    subject_string = message.sender.name + "on lähettänyt sinulle viestin Kassissa"
    recipients recipient.email
    from       KASSI_MAIL_FROM_ADRESS
    subject    subject_string
    body       :recipient => recipient, :message => message
  end

end

