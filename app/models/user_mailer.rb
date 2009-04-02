class UserMailer < ActionMailer::Base

  def notification_of_new_message(recipient, message, request=nil)
    subject_string = message.sender.name + ' on lähettänyt sinulle viestin Kassissa'
    url = request ? "#{request.protocol}#{request.host}#{person_inbox_path(@recipient, @message.conversation)}" : "test_url"
    recipients recipient.email
    from       KASSI_MAIL_FROM_ADRESS
    subject    subject_string
    body       :recipient => recipient, :message => message, :url => url
  end
  
  def notification_of_new_comment(comment, request=nil)
    subject_string = comment.author.name + ' on kommentoinut ilmoitustasi "' + comment.listing.title + '"'
    url = request ? "#{request.protocol}#{request.host}#{listing_path(@comment.listing.id)}##{@comment.id}" : "test_url"
    recipients comment.listing.author.email
    from       KASSI_MAIL_FROM_ADRESS
    subject    subject_string
    body       :comment => comment, :url => url
  end

end

