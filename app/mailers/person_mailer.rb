include ApplicationHelper

class PersonMailer < ActionMailer::Base
  default :from => "Kassi <kassi@sizl.org>"
  layout 'email'

  def new_message_notification(message, host=nil)
    recipient = message.conversation.other_party(message.sender)
    @url = host ? "http://#{host}/#{recipient.locale}#{person_message_path(:person_id => recipient.id, :id => message.conversation.id.to_s)}" : "test_url"
    @settings_url = host ? "http://#{host}/#{recipient.locale}#{notifications_person_settings_path(:person_id => recipient.id)}" : "test_url"
    @message = message
    set_locale recipient.locale
    mail(:to => recipient.email,
         :subject => t("emails.new_message.you_have_a_new_message"))
  end
  
  def new_comment_to_own_listing_notification(comment, host=nil)
    recipient = comment.listing.author
    @url = host ? "http://#{host}/#{recipient.locale}#{listing_path(:id => comment.listing.id.to_s)}" : "test_url"
    @settings_url = host ? "http://#{host}/#{recipient.locale}#{notifications_person_settings_path(:person_id => recipient.id)}" : "test_url"
    @comment = comment
    set_locale recipient.locale
    mail(:to => recipient.email,
         :subject => t("emails.new_comment.you_have_a_new_comment", :author => comment.author.name))
  end
  
  def conversation_status_changed(conversation, host=nil)
    recipient = conversation.other_party(conversation.listing.author)
    @url = host ? "http://#{host}/#{recipient.locale}#{person_message_path(:person_id => recipient.id, :id => conversation.id.to_s)}" : "test_url"
    @settings_url = host ? "http://#{host}/#{recipient.locale}#{notifications_person_settings_path(:person_id => recipient.id)}" : "test_url"
    @conversation = conversation
    set_locale recipient.locale
    mail(:to => recipient.email,
         :subject => t("emails.conversation_status_changed.your_#{Listing.opposite_type(conversation.listing.listing_type)}_was_#{conversation.status}"))
  end
  
  def new_badge(badge, host=nil)
    recipient = badge.person
    @url = host ? "http://#{host}/#{recipient.locale}#{person_badges_path(:person_id => recipient.id)}" : "test_url"
    @settings_url = host ? "http://#{host}/#{recipient.locale}#{notifications_person_settings_path(:person_id => recipient.id)}" : "test_url"
    @badge = badge
    @badge_name = t("people.profile_badge.#{@badge.name}")
    set_locale recipient.locale
    mail(:to => recipient.email,
         :subject => t("emails.new_badge.you_have_achieved_a_badge", :badge_name => @badge_name))
  end
  
  def new_testimonial(testimonial, host=nil)
    recipient = testimonial.receiver
    @url = host ? "http://#{host}/#{recipient.locale}#{person_testimonials_path(:person_id => recipient.id)}" : "test_url"
    @settings_url = host ? "http://#{host}/#{recipient.locale}#{notifications_person_settings_path(:person_id => recipient.id)}" : "test_url"
    @testimonial = testimonial
    set_locale recipient.locale
    mail(:to => recipient.email,
         :subject => t("emails.new_testimonial.has_given_you_feedback_in_kassi", :name => recipient.name))
  end
  
  # Used to send notification to Kassi admins when somebody
  # gives feedback on Kassi
  def new_feedback(feedback)
    @feedback = feedback
    subject = "Uutta palautetta #{APP_CONFIG.production_server}-Kassista käyttäjältä #{feedback.author.try(:name)}"
    mail(:to => APP_CONFIG.feedback_mailer_recipients, :subject => subject)
  end

end