class UserMailer < ActionMailer::Base

  def notification_of_new_message(recipient, message, request=nil)
    subject_string = message.sender.name + ' on lähettänyt sinulle viestin Kassissa'
    url = request ? "#{request.protocol}#{request.host}#{person_inbox_path(recipient, message.conversation)}" : "test_url"
    settings_url = request ? "#{request.protocol}#{request.host}#{person_settings_path(recipient.id)}" : "test_url"
    recipients recipient.email
    from       KASSI_MAIL_FROM_ADDRESS
    subject    subject_string
    body       :recipient => recipient, :message => message, :url => url, :settings_url => settings_url
  end
  
  def notification_of_new_comment(comment, request=nil)
    subject_string = comment.author.name + ' on kommentoinut ilmoitustasi "' + comment.listing.title + '"'
    url = request ? "#{request.protocol}#{request.host}#{listing_path(comment.listing.id)}##{comment.id}" : "test_url"
    settings_url = request ? "#{request.protocol}#{request.host}#{person_settings_path(comment.listing.author.id)}" : "test_url"
    recipients comment.listing.author.email
    from       KASSI_MAIL_FROM_ADDRESS
    subject    subject_string
    body       :comment => comment, :url => url, :settings_url => settings_url
  end
  
  def notification_of_new_friend_request(requester, requested, http_request=nil)
    subject_string = requester.name + ' on lisännyt sinut kaveriksi Kassissa."'
    url = http_request ? "#{http_request.protocol}#{http_request.host}#{person_requests_path(requested.id)}" : "test_url"
    settings_url = http_request ? "#{http_request.protocol}#{http_request.host}#{person_settings_path(requested.id)}" : "test_url"
    recipients requested.email
    from       KASSI_MAIL_FROM_ADDRESS
    subject    subject_string
    body       :requester => requester, :url => url, :settings_url => settings_url
  end

end

