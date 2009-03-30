class UserMailer < ActionMailer::Base

  def notification_of_new_message(recipient, message, cookie)
    subject_string = message.sender.name + "on lähettänyt sinulle viestin Kassissa"
    recipients recipient.email(cookie)
    from       KASSI_MAIL_FROM_ADRESS
    subject    subject_string
    body       :recipient => recipient, :message => message
  end
  
  def notification_of_new_comment(comment, cookie)
    subject_string = comment.author.name + 'on kommentoinut ilmoitustasi "' + comment.listing.title + '"'
    recipients comment.listing.author.email(cookie)
    from       KASSI_MAIL_FROM_ADRESS
    subject    subject_string
    body       :comment => comment
  end
  
  # Lines that produce response URLs in the mail body
  # <%= "#{@request.protocol}#{@request.host}#{listing_path(@comment.listing.id)}##{@comment.id}" %>
  # <%= "#{@request.protocol}#{@request.host}#{person_inbox_path(@recipient, @message.conversation)}" %>

end

