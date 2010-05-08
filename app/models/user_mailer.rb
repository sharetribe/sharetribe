class UserMailer < ActionMailer::Base

  #layout 'email'
  
  include ListingsHelper

  def notification_of_new_message(recipient, message, request=nil)
    set_locale  recipient.locale
    subject_string = t(:new_message_in_kassi, :sender => message.sender.name)
    url = request ? "http://#{request.host}#{person_inbox_path(recipient, message.conversation)}" : "test_url"
    settings_url = request ? "http://#{request.host}#{person_settings_path(recipient.id)}" : "test_url"
    recipients recipient.email
    from       APP_CONFIG.kassi_mail_from_address
    subject    subject_string
    body       :recipient => recipient, :message => message, :url => url, :settings_url => settings_url
  end
  
  # Used to send a notification to the listing author
  def notification_of_new_comment(comment, host=nil)
    set_locale  comment.listing.author.locale
    subject_string = comment.author.name + " on kommentoinut ilmoitustasi"
    url = host ? "http://#{host}#{listing_path(comment.listing.id)}" : "test_url"
    settings_url = host ? "http://#{host}#{person_settings_path(comment.listing.author.id)}" : "test_url"
    recipients comment.listing.author.email
    from       APP_CONFIG.kassi_mail_from_address
    subject    subject_string
    body       :comment => comment, :url => url, :settings_url => settings_url, :listing_title => get_title_with_category(comment.listing)
  end
  
  # Used to send a notification to people who have commented the listing and are not listing authors
  def notification_of_new_comment_to_followed_listing(comment, recipient, host=nil)
    set_locale  recipient.locale
    subject_string = comment.author.name + " on kommentoinut ilmoitusta jota seuraat"
    url = host ? "http://#{host}#{listing_path(comment.listing.id)}" : "test_url"
    settings_url = host ? "http://#{host}#{person_settings_path(recipient.id)}" : "test_url"
    recipients recipient.email
    from       APP_CONFIG.kassi_mail_from_address
    subject    subject_string
    body       :comment => comment, :url => url, :settings_url => settings_url, :listing_title => get_title_with_category(comment.listing)
  end
  
  # Used to send a notification to people who have commented the listing and are not listing authors
  def notification_of_new_update_to_listing(listing, recipient, host=nil)
    set_locale  recipient.locale
    subject_string = t(:listing_you_follow_has_been_updated)
    url = host ? "http://#{host}#{listing_path(listing.id)}" : "test_url"
    settings_url = host ? "http://#{host}#{person_settings_path(recipient.id)}" : "test_url"
    recipients recipient.email
    from       APP_CONFIG.kassi_mail_from_address
    subject    subject_string
    body       :listing => listing, :url => url, :settings_url => settings_url, :recipient => recipient, :listing_title => get_title_with_category(listing)
  end
  
  def notification_of_new_friend_request(requester, requested, http_request=nil)
    set_locale  requested.locale
    subject_string = requester.name + ' on lisännyt sinut kaveriksi Kassissa'
    url = http_request ? "http://#{http_request.host}#{person_requests_path(requested.id)}" : "test_url"
    settings_url = http_request ? "http://#{http_request.host}#{person_settings_path(requested.id)}" : "test_url"
    recipients requested.email
    from       APP_CONFIG.kassi_mail_from_address
    subject    subject_string
    body       :requester => requester, :url => url, :settings_url => settings_url 
  end
  
  def notification_of_new_kassi_event(recipient, kassi_event, http_request=nil)
    set_locale  recipient.locale
    subject_string = 'Uusi kassitapahtuma'
    url = http_request ? "http://#{http_request.host}#{person_kassi_event_path(recipient, kassi_event)}" : "test_url"
    settings_url = http_request ? "http://#{http_request.host}#{person_settings_path(recipient.id)}" : "test_url"
    recipients recipient.email
    from       APP_CONFIG.kassi_mail_from_address
    subject    subject_string
    body       :recipient => recipient, :kassi_event => kassi_event, :url => url, :settings_url => settings_url
  end
  
  def notification_of_new_comment_to_kassi_event(recipient, kassi_event, http_request=nil)
    set_locale  recipient.locale
    subject_string = kassi_event.get_other_party(recipient).name + " on antanut sinulle palautetta kassitapahtumasta"
    url = http_request ? "http://#{http_request.host}#{person_kassi_event_path(recipient, kassi_event)}" : "test_url"
    settings_url = http_request ? "http://#{http_request.host}#{person_settings_path(recipient.id)}" : "test_url"
    recipients recipient.email
    from       APP_CONFIG.kassi_mail_from_address
    subject    subject_string
    body       :recipient => recipient, :kassi_event => kassi_event, :url => url, :settings_url => settings_url
  end
  
  def notification_of_new_listing_from_friend(listing, friend, host=nil)
    set_locale  friend.locale
    subject_string = listing.author.name + " on lähettänyt Kassiin uuden ilmoituksen"
    url = host ? "http://#{host}#{listing_path(listing)}" : "test_url"
    settings_url = host ? "http://#{host}#{person_settings_path(friend.id)}" : "test_url"
    recipients friend.email
    from       APP_CONFIG.kassi_mail_from_address
    subject    subject_string
    body       :listing => listing, :url => url, :settings_url => settings_url, :listing_title => get_title_with_category(listing)
  end
  
  def notification_of_new_feedback(feedback, http_request=nil)
    subject_string = "Uutta palautetta #{PRODUCTION_SERVER}-Kassista käyttäjältä #{feedback.author.try(:name)}"
    url = http_request ? "http://#{http_request.host}#{admin_feedbacks_path}" : "test_url"
    recipients APP_CONFIG.feedback_mailer_recipients
    from       APP_CONFIG.kassi_mail_from_address
    subject    subject_string
    body       :url => url, :feedback => feedback
  end

end

