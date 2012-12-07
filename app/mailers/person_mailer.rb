# encoding: UTF-8

include ApplicationHelper
include PeopleHelper
include ListingsHelper
include TruncateHtmlHelper

class PersonMailer < ActionMailer::Base
  
  # Enable use of method to_date.
  require 'active_support/core_ext'
  
  require "truncate_html"
  
  default :from => APP_CONFIG.sharetribe_mail_from_address, :reply_to => APP_CONFIG.sharetribe_reply_to_address
  
  layout 'email'

  def new_message_notification(message, host=nil)
    @recipient = set_up_recipient(message.conversation.other_party(message.sender), host)
    @url = host ? "http://#{host}/#{@recipient.locale}#{person_message_path(:person_id => @recipient.id, :id => message.conversation.id.to_s)}" : "test_url"
    @message = message
    alert_if_erroneus_host(host, @url)
    mail(:to => @recipient.email,
         :subject => t("emails.new_message.you_have_a_new_message"),
         :reply_to => APP_CONFIG.sharetribe_mail_from_address) 
         # reply_to no-reply address so that people notice immediately that it didn't work
         # and hopefully read the actual message and answer with the link 
  end
  
  def new_comment_to_own_listing_notification(comment, host=nil)
    @recipient = set_up_recipient(comment.listing.author, host)
    @url = host ? "http://#{host}/#{@recipient.locale}#{listing_path(:id => comment.listing.id.to_s)}##{comment.id.to_s}" : "test_url"
    @comment = comment
    alert_if_erroneus_host(host, @url)
    mail(:to => @recipient.email,
         :subject => t("emails.new_comment.you_have_a_new_comment", :author => comment.author.name))
  end
  
  def new_comment_to_followed_listing_notification(comment, recipient, host=nil)
    @recipient = set_up_recipient(recipient, host)
    @url = host ? "http://#{host}/#{@recipient.locale}#{listing_path(:id => comment.listing.id.to_s)}##{comment.id.to_s}" : "test_url"
    @comment = comment
    alert_if_erroneus_host(host, @url)
    mail(:to => @recipient.email,
         :subject => t("emails.new_comment.listing_you_follow_has_a_new_comment", :author => comment.author.name))
  end
  
  def new_update_to_followed_listing_notification(listing, recipient, host=nil)
    @recipient = set_up_recipient(recipient, host)
    @url = host ? "http://#{host}/#{@recipient.locale}#{listing_path(:id => listing.id.to_s)}" : "test_url"
    @listing = listing
    alert_if_erroneus_host(host, @url)
    mail(:to => @recipient.email,
         :subject => t("emails.new_update_to_listing.listing_you_follow_has_been_updated"))
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
  
  # Used to send notification to Sharetribe admins when somebody
  # gives feedback on Sharetribe
  def new_feedback(feedback, current_community)
    @no_settings = true
    @feedback = feedback
    @feedback.email ||= feedback.author.try(:email)
    @current_community = current_community
    subject = "New #unanswered #feedback from #{@current_community.name} community from user #{feedback.author.try(:name)} "
    mail_to = APP_CONFIG.feedback_mailer_recipients + (@current_community.feedback_to_admin? ? ", #{@current_community.admin_emails.join(",")}" : "")
    mail(:to => mail_to, :subject => subject, :reply_to => @feedback.email)
  end
  
  def badge_migration_notification(recipient)
    @recipient = recipient
    set_locale @recipient.locale
    @no_settings = true
    @url = "http://aalto.sharetribe.com/#{@recipient.locale}#{person_badges_path(:person_id => @recipient.id)}"
    mail(:to => recipient.email, :subject => t("emails.badge_migration_notification.you_have_received_badges"))
  end
  
  # Used to send notification to Sharetribe admins when somebody
  # wants to contact them through the form in the dashboard
  def contact_request_notification(email)
    @no_settings = true
    @email = email
    subject = "New contact request"
    mail(:to => APP_CONFIG.feedback_mailer_recipients, :subject => subject)
  end
  
  def new_member_notification(person, community, email)
    @community = Community.find_by_domain(community)
    @no_settings = true
    @person = person
    @email = email
    mail(:to => @community.admin_emails, :subject => "New member in #{@community.name} Sharetribe")
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
  
  # The initial email confirmation is sent by Devise, but if people enter additional emails, confirm them with this method
  # using the same template
  def additional_email_confirmation(email, host)
    @no_settings = true
    @resource = email.person
    @confirmation_token = email.confirmation_token
    @host = host
    mail(:to => email.address, :subject => t("devise.mailer.confirmation_instructions.subject"), :template_path => 'devise/mailer', :template_name => 'confirmation_instructions')
  end
  
  def community_updates(recipient, community)
    @community = community
    @recipient = recipient
    
    unless @recipient.member_of?(@community)
      logger.info "Trying to send community updates to a person who is not member of the given community. Skipping."
      return
    end

    set_locale @recipient.locale
    @url_base = "http://#{@community.full_domain}/#{recipient.locale}"
    @settings_url = "#{@url_base}#{notifications_person_settings_path(:person_id => recipient.id)}"
    @requests = @community.listings.currently_open.requests.visible_to(@recipient, @community).limit(5)
    @offers = @community.listings.currently_open.offers.visible_to(@recipient, @community).limit(5)
  
    if APP_CONFIG.mail_delivery_method == "postmark"
      # Postmark doesn't support bulk emails, so use Sendmail for this
      delivery_method = :sendmail
    else
      delivery_method = APP_CONFIG.mail_delivery_method.to_sym
    end
  
    mail(:to => @recipient.email,
         :subject => t("emails.newsletter.weekly_news_from_kassi", :community => @community.name_with_separator(@recipient.locale)),
         :delivery_method => delivery_method) do |format|
      format.html { render :layout => false }
    end
  end
  
  def newsletter(recipient, newsletter_filename)
    
    @recipient = recipient
    set_locale recipient.locale
    
    @newsletter_path = "newsletters/#{newsletter_filename}.#{@recipient.locale}.html"
    @newsletter_content = File.read("public/#{@newsletter_path}")
    
    @community = recipient.communities.first # We pick random community to point the settings link to
    
    @url_base = "http://#{@community.full_domain}/#{recipient.locale}"
    @settings_url = "#{@url_base}#{notifications_person_settings_path(:person_id => recipient.id)}"
    
    mail(:to => @recipient.email, :subject => t("emails.newsletter.occasional_newsletter_title")) do |format|
      format.html { render :layout => "newsletter" }
    end
  end
  
  def invitation_to_kassi(invitation, host=nil)
    @no_settings = true
    @invitation = invitation
    set_locale @invitation.inviter.locale
    @url = host ? "http://#{host}/#{@invitation.inviter.locale}/signup?code=#{@invitation.code}" : "test_url"
    @url += "&private_community=true" if @invitation.community.private?
    subject = t("emails.invitation_to_kassi.you_have_been_invited_to_kassi", :inviter => @invitation.inviter.name, :community => @invitation.community.name)
    mail(:to => @invitation.email, :subject => subject, :reply_to => @invitation.inviter.email)
  end
  
  # This is used by console script that creates a list of user accounts and sends an email to all
  # Currently only in spanish, as not yet needed in other languages
  def automatic_account_created(recipient, password)
    @no_settings = true
    @username = recipient.username
    @given_name = recipient.given_name
    @password = password
    subject = "Tienes una cuenta creada para la comunidad Diseño UDD de Sharetribe"
    
    if APP_CONFIG.mail_delivery_method == "postmark"
      # Postmark doesn't support bulk emails, so use Sendmail for this
      delivery_method = :sendmail
    else
      delivery_method = APP_CONFIG.mail_delivery_method.to_sym
    end
    
    mail(:to => recipient.email, :subject => subject, :reply_to => "diego@sharetribe.com", :delivery_method => delivery_method)
  end
  
  # This method can send any plain text mail where subject and mail contents are given in parameters.
  # Only thing added to contents is "Hi (user's name),"
  def open_content_message(recipient, subject, mail_content, default_locale="en")
    @no_settings = true
    @recipient = recipient
    @subject = subject
    if @recipient.locale == "ca" || @recipient.locale == "es-ES"
      if mail_content["es"].present?
        # special change for ca and es-ES 
        # because those probably don't have separate texts in neaer future
        # but we probably have spanish, so it makes more sense as fallback than english.
        default_locale = "es"
      end
    end
    
    # Set mail contents, which can be a string or hash containing contents for many languages
    # For example:
    # {"en" => {"subject" => "changes coming", "body" => "We're doing new stuff\nCheck it out at..."}, "fi" => {etc.}}    
    if mail_content.class == String
      @mail_content = mail_content
    elsif mail_content.class == Hash
      if mail_content[@recipient.locale].present?
        @mail_content = mail_content[@recipient.locale]["body"]
        @subject = mail_content[@recipient.locale]["subject"]
        set_locale @recipient.locale
      elsif default_locale && mail_content[default_locale].present?
        @mail_content = mail_content[default_locale]["body"]
        @subject = mail_content[default_locale]["subject"]
        set_locale default_locale
      else
        throw "No content with user's locale #{recipient.locale}, and no working default provided."
      end    
    else
      throw "Unknown type for mail_content"
    end

    # disable escaping since this is currently always coming from trusted source.
    @mail_content = @mail_content.html_safe
    
    mail(:to => @recipient.email, :subject => @subject)
  end
  
  def self.deliver_community_updates
    Community.all.each do |community|
      if community.created_at < 1.week.ago && community.listings.size > 5 && community.automatic_newsletters
        community.members.each do |member|
          if member.should_receive?("email_about_weekly_events")
            begin
              PersonMailer.community_updates(member, community).deliver
            rescue Exception => e
              # Catch the exception and continue sending the news letter
              ApplicationHelper.send_error_notification("Error sending mail for weekly community updates: #{e.message}", e.class)
            end
          end
        end
      end
    end
  end
  
  def self.deliver_newsletters(newsletter_filename)
    unless File.exists?("public/newsletters/#{newsletter_filename}.en.html")
      puts "Can't find the newsletter file in english (public/newsletters/#{newsletter_filename}.en.html) Maybe you mistyped the first part of filename?"
      return
    end
    
    Person.all.each do |person|
      if person.should_receive?("email_newsletters")
        begin
          if File.exists?("public/newsletters/#{newsletter_filename}.#{person.locale}.html")
            PersonMailer.newsletter(person, newsletter_filename).deliver
          else
            logger.debug "Skipping sending newsletter to #{person.username}, because his locale is #{person.locale} and that file was not found."
          end
        rescue Exception => e
          # Catch the exception and continue sending the newsletter
          ApplicationHelper.send_error_notification("Error sending newsletter for #{person.username}: #{e.message}", e.class)
        end
      end 
    end;"Newsletters sent"
  end  
  
  def self.deliver_open_content_messages(people_array, subject, mail_content, default_locale="en", verbose=false, addresses_to_skip=[])
    people_array.each do |person|
      # only send mail to people whose profile is active and not asked to be skipped
      if person.active && ! addresses_to_skip.include?(person.email)
        begin
          PersonMailer.open_content_message(person, subject, mail_content, default_locale).deliver
        rescue Exception => e
          ApplicationHelper.send_error_notification("Error sending open content email: #{e.message}", e.class)
        end
        if verbose #main intention of this is to get feedback while sending mass emails from console.
          print "."; STDOUT.flush
        end
      else
        print "s" if verbose # (skipped)
      end
    end
    puts "\nSending mails finished" if verbose
    
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