include ApplicationHelper
include PeopleHelper

class PersonMailer < ActionMailer::Base
  
  # Enable use of method to_date.
  require 'active_support/core_ext'
  
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
    subject = "New #unanswered #feedback from #{@current_community.name} community from user #{feedback.author.try(:name)} "
    mail_to = @current_community.feedback_to_admin? ? @current_community.admin_emails : APP_CONFIG.feedback_mailer_recipients
    mail(:to => mail_to, :subject => subject, :reply_to => @feedback.email)
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
    mail(:to => @community.admin_emails, :subject => "New member in #{@community.name} Kassi")
  end
  
  # Automatic reply to people who try to contact us via Dashboard
  def reply_to_contact_request(email, locale)
    @no_settings = true
    set_locale locale
    mail(:to => email, :subject => t("emails.reply_to_contact_request.thank_you_for_your_interest"), :from => "Juho Makkonen <info@kassi.eu>")
  end
  
  # Remind users of conversations that have not been accepted or rejected
  def accept_reminder(conversation, recipient, host=nil)
    @recipient = set_up_recipient(recipient, host)
    @conversation = conversation
    @url = host ? "http://#{host}/#{@recipient.locale}#{person_message_path(:person_id => @recipient.id, :id => @conversation.id.to_s)}" : "test_url"
    alert_if_erroneus_host(host, @url)
    mail(:to => @recipient.email,
         :subject => t("emails.accept_reminder.remember_to_accept_#{@conversation.discussion_type}"))
  end
  
  def newsletter(recipient, community)
    @community = community
    @recipient = recipient
    set_locale @recipient.locale
    @url_base = "http://#{@community.domain}.#{APP_CONFIG.domain}/#{recipient.locale}"
    @settings_url = "#{@url_base}#{notifications_person_settings_path(:person_id => recipient.id)}"
    @requests = @community.listings.open.requests.visible_to(@recipient, @community).limit(5)
    @offers = @community.listings.open.offers.visible_to(@recipient, @community).limit(5)
    mail(:to => @recipient.email,
         :subject => t("emails.newsletter.weekly_news_from_kassi", :community => @community.name_with_separator(@recipient.locale)),
         :delivery_method => :sendmail)
  end
  
  def self.deliver_newsletters
    Community.all.each do |community|
      if community.created_at < 1.week.ago && community.listings.size > 5 && community.automatic_newsletters
        community.members.each do |member|
          if member.should_receive?("email_about_weekly_events")
            begin
              PersonMailer.newsletter(member, community).deliver
            rescue Exception => e
              # Catch the exception and continue sending the news letter
              ApplicationHelper.send_error_notification("Error sending mail for weekly newsletter: #{e.message}", e.class)
            end
          end
        end
      end
    end
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