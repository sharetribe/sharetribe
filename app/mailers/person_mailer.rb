include ApplicationHelper
include PeopleHelper

class PersonMailer < ActionMailer::Base
  default :from => APP_CONFIG.kassi_mail_from_address
  layout 'email'

  def new_message_notification(message, host=nil)
    @recipient = set_up_recipient(message.conversation.other_party(message.sender), host)
    @url = host ? "http://#{host}/#{@recipient.locale}#{person_message_path(:person_id => @recipient.id, :id => message.conversation.id.to_s)}" : "test_url"
    @message = message
    alert_if_erroneus_host(host, @url)
    mail(:to => @recipient.email,
         :subject => t("emails.new_message.you_have_a_new_message"))
  end
  
  def new_comment_to_own_listing_notification(comment, host=nil)
    @recipient = set_up_recipient(comment.listing.author, host)
    @url = host ? "http://#{host}/#{@recipient.locale}#{listing_path(:id => comment.listing.id.to_s)}" : "test_url"
    @comment = comment
    alert_if_erroneus_host(host, @url)
    mail(:to => @recipient.email,
         :subject => t("emails.new_comment.you_have_a_new_comment", :author => comment.author.name))
  end
  
  def conversation_status_changed(conversation, host=nil)
    @recipient = set_up_recipient(conversation.other_party(conversation.listing.author), host)
    @url = host ? "http://#{host}/#{@recipient.locale}#{person_message_path(:person_id => @recipient.id, :id => conversation.id.to_s)}" : "test_url"
    @conversation = conversation
    alert_if_erroneus_host(host, @url)
    mail(:to => @recipient.email,
         :subject => t("emails.conversation_status_changed.your_#{Listing.opposite_type(conversation.listing.listing_type)}_was_#{conversation.status}"))
  end
  
  def new_badge(badge, host=nil)
    @recipient = set_up_recipient(badge.person, host)
    @url = host ? "http://#{host}/#{@recipient.locale}#{person_badges_path(:person_id => @recipient.id)}" : "test_url"
    @badge = badge
    @badge_name = t("people.profile_badge.#{@badge.name}")
    alert_if_erroneus_host(host, @url)
    mail(:to => @recipient.email,
         :subject => t("emails.new_badge.you_have_achieved_a_badge", :badge_name => @badge_name))
  end
  
  def new_testimonial(testimonial, host=nil)
    @recipient = set_up_recipient(testimonial.receiver, host)
    @url = host ? "http://#{host}/#{@recipient.locale}#{person_testimonials_path(:person_id => @recipient.id)}" : "test_url"
    @give_feedback_url = host ? "http://#{host}/#{@recipient.locale}#{new_person_message_feedback_path(:person_id => @recipient.id, :message_id => testimonial.participation.conversation.id)}" : "test_url"
    @testimonial = testimonial
    alert_if_erroneus_host(host, @url)
    mail(:to => @recipient.email,
         :subject => t("emails.new_testimonial.has_given_you_feedback_in_kassi", :name => @testimonial.author.name))
  end
  
  def testimonial_reminder(participation, host=nil)
    @recipient = set_up_recipient(participation.person, host)
    @url = host ? "http://#{host}/#{@recipient.locale}#{new_person_message_feedback_path(:person_id => @recipient.id, :message_id => participation.conversation.id)}" : "test_url"
    @participation = participation
    @other_party = @participation.conversation.other_party(@participation.person)
    alert_if_erroneus_host(host, @url)
    mail(:to => @recipient.email,
         :subject => t("emails.testimonial_reminder.remember_to_give_feedback_to", :name => @other_party.name))
  end
  
  # Used to send notification to Kassi admins when somebody
  # gives feedback on Kassi
  def new_feedback(feedback, current_community)
    @no_settings = true
    @feedback = feedback
    @feedback.email ||= feedback.author.try(:email)
    @current_community = current_community
    subject = "Uutta palautetta #{@current_community.name}-Kassista käyttäjältä #{feedback.author.try(:name)}"
    mail(:to => APP_CONFIG.feedback_mailer_recipients, :subject => subject, :reply_to => @feedback.email)
  end
  
  def badge_migration_notification(recipient)
    @recipient = recipient
    set_locale @recipient.locale
    @no_settings = true
    @url = "http://aalto.kassi.eu/#{@recipient.locale}#{person_badges_path(:person_id => @recipient.id)}"
    mail(:to => recipient.email, :subject => t("emails.badge_migration_notification.you_have_received_badges"))
  end
  
  # Used to send notification to Kassi admins when somebody
  # wants to contact them through the form in the dashboard
  def contact_request_notification(email)
    @no_settings = true
    @email = email
    subject = "Uusi yhteydenottopyyntö #{APP_CONFIG.server_name}-Kassista"
    mail(:to => APP_CONFIG.feedback_mailer_recipients, :subject => subject)
  end
  
  def new_member_notification(person, community, email)
    @community = Community.find_by_domain(community)
    @no_settings = true
    @person = person
    @email = email
    admin_emails = Person.admins_of(@community).collect { |p| p.email }
    mail(:to => admin_emails, :subject => "New member in #{@community.name} Kassi")
  end
  
  private
  
  def set_up_recipient(recipient, host=nil)
    @settings_url = host ? "http://#{host}/#{recipient.locale}#{notifications_person_settings_path(:person_id => recipient.id)}" : "test_url"
    set_locale recipient.locale
    recipient
  end
  
  def alert_if_erroneus_host(host, sent_link="not_available")
    if host =~ /login/
      ApplicationHelper.send_error_notification("Sending mail with LOGIN host: #{host}, which should not happen!", "Mailer domain error", params.merge({:sent_link => sent_link}))
    end
  end

end