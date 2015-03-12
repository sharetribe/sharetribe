# encoding: utf-8

include ApplicationHelper
include PeopleHelper
include ListingsHelper
include TruncateHtmlHelper

class PersonMailer < ActionMailer::Base
  include MailUtils

  # Enable use of method to_date.
  require 'active_support/core_ext'

  require "truncate_html"

  default :from => APP_CONFIG.sharetribe_mail_from_address
  layout 'email'

  add_template_helper(EmailTemplateHelper)

  def conversation_status_changed(transaction, community)
    @email_type =  (transaction.status == "accepted" ? "email_when_conversation_accepted" : "email_when_conversation_rejected")
    set_up_urls(transaction.other_party(transaction.listing.author), community, @email_type)
    @transaction = transaction

    if @transaction.payment_gateway == "braintree" ||  @transaction.payment_process == "postpay"
      # Payment url concerns only braintree and postpay, otherwise we show only the message thread
      @payment_url = community.payment_gateway.new_payment_url(@recipient, @transaction, @recipient.locale, @url_params)
    end

    premailer_mail(:to => @recipient.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :subject => t("emails.conversation_status_changed.your_request_was_#{transaction.status}"))
  end

  def new_message_notification(message, community)
    @email_type =  "email_about_new_messages"
    set_up_urls(message.conversation.other_party(message.sender), community, @email_type)
    @message = message
    sending_params = {:to => @recipient.confirmed_notification_emails_to,
         :subject => t("emails.new_message.you_have_a_new_message", :sender_name => message.sender.name(community)),
         :from => community_specific_sender(community)}

    premailer_mail(sending_params)
  end

  def new_payment(payment, community)
    @email_type =  "email_about_new_payments"
    @payment = payment
    set_up_urls(@payment.recipient, community, @email_type)
    premailer_mail(:to => @recipient.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :subject => t("emails.new_payment.new_payment"))
  end

  def receipt_to_payer(payment, community)
    @email_type =  "email_about_new_payments"
    @payment = payment
    set_up_urls(@payment.payer, community, @email_type)
    premailer_mail(:to => @recipient.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :subject => t("emails.receipt_to_payer.receipt_of_payment"))
  end

  def transaction_confirmed(conversation, community)
    @email_type =  "email_about_completed_transactions"
    @conversation = conversation
    set_up_urls(@conversation.seller, community, @email_type)
    premailer_mail(:to => @recipient.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :subject => t("emails.transaction_confirmed.request_marked_as_#{@conversation.status}"))
  end

  def transaction_automatically_confirmed(conversation, community)
    @email_type =  "email_about_completed_transactions"
    @conversation = conversation
    set_up_urls(@conversation.buyer, community, @email_type)
    premailer_mail(:to => @recipient.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :template_path => 'person_mailer/automatic_confirmation',
         :subject => t("emails.transaction_automatically_confirmed.subject"))
  end

  def booking_transaction_automatically_confirmed(transaction, community)
    @email_type = "email_about_completed_transactions"
    @transaction = transaction
    set_up_urls(@transaction.bueyr, community, @email_type)
    mail(:to => @recipient.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :template_path => 'person_mailer/automatic_confirmation',
         :subject => t("emails.booking_transaction_automatically_confirmed.subject"))
  end

  def escrow_canceled_to(conversation, community, to)
    @email_type =  "email_about_canceled_escrow"
    @conversation = conversation
    set_up_urls(@conversation.seller, community, @email_type)
    premailer_mail(:to => to,
         :from => community_specific_sender(community),
         :subject => t("emails.escrow_canceled.subject")) do |format|
      format.html { render "escrow_canceled" }
    end
  end

  def escrow_canceled(conversation, community)
    escrow_canceled_to(conversation, community, conversation.seller.confirmed_notification_emails_to)
  end

  def admin_escrow_canceled(conversation, community)
    escrow_canceled_to(conversation, community, community.admin_emails.join(","))
  end

  def new_testimonial(testimonial, community)
    @email_type =  "email_about_new_received_testimonials"
    set_up_urls(testimonial.receiver, community, @email_type)
    @testimonial = testimonial
    premailer_mail(:to => @recipient.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :subject => t("emails.new_testimonial.has_given_you_feedback_in_kassi", :name => @testimonial.author.name(community)))
  end

  # Remind users of conversations that have not been accepted or rejected
  # NOTE: the not_really_a_recipient is at the same spot in params
  # to keep the call structure similar for reminder mails
  # but the actual recipient is always the listing author.
  def accept_reminder(conversation, not_really_a_recipient, community)
    @email_type = "email_about_accept_reminders"
    set_up_urls(conversation.listing.author, community, @email_type)
    @conversation = conversation
    premailer_mail(:to => @recipient.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :subject => t("emails.accept_reminder.remember_to_accept_request", :sender_name => @conversation.other_party(@recipient).name(community)))
  end

  # Remind users to pay
  def payment_reminder(conversation, recipient, community)
    @email_type = "email_about_payment_reminders"
    set_up_urls(conversation.payment.payer, community, @email_type)
    @conversation = conversation

    @pay_url = payment_url(conversation, recipient, @url_params)

    premailer_mail(:to => @recipient.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :subject => t("emails.payment_reminder.remember_to_pay", :listing_title => @conversation.listing.title))
  end

  # Remind user to fill in payment details
  def payment_settings_reminder(listing, recipient, community)
    set_up_urls(recipient, community)
    @listing = listing
    @recipient = recipient

    if community.payments_in_use?
      @payment_settings_link = payment_settings_url(MarketplaceService::Community::Query.payment_type(community.id), recipient, @url_params)
    end

    premailer_mail(:to => recipient.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :subject => t("emails.payment_settings_reminder.remember_to_add_payment_details")) do |format|
            format.html {render :locals => {:skip_unsubscribe_footer => true} }
    end
  end

  # Braintree account was approved (via Webhook)
  def braintree_account_approved(recipient, community)
    set_up_urls(recipient, community)
    @recipient = recipient

    premailer_mail(:to => recipient.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :subject => t("emails.braintree_account_approved.account_ready")) do |format|
            format.html {render :locals => {:skip_unsubscribe_footer => true} }
    end
  end

  # Remind users of conversations that have not been accepted or rejected
  def confirm_reminder(conversation, recipient, community, days_to_cancel)
    @email_type = "email_about_confirm_reminders"
    set_up_urls(conversation.bueyr, community, @email_type)
    @conversation = conversation
    @days_to_cancel = days_to_cancel
    escrow = community.payment_gateway && community.payment_gateway.hold_in_escrow
    template = escrow ? "confirm_reminder_escrow" : "confirm_reminder"
    premailer_mail(:to => @recipient.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :subject => t("emails.confirm_reminder.remember_to_confirm_request")) do |format|
      format.html { render template }
    end
  end

  # Remind users to give feedback
  def testimonial_reminder(conversation, recipient, community)
    @email_type = "email_about_testimonial_reminders"
    set_up_urls(recipient, community, @email_type)
    @conversation = conversation
    @other_party = @conversation.other_party(@recipient)
    premailer_mail(:to => @recipient.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :subject => t("emails.testimonial_reminder.remember_to_give_feedback_to", :name => @other_party.name))
  end

  def new_comment_to_own_listing_notification(comment, community)
    @email_type = "email_about_new_comments_to_own_listing"
    set_up_urls(comment.listing.author, community, @email_type)
    @comment = comment
    premailer_mail(:to => @recipient.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :subject => t("emails.new_comment.you_have_a_new_comment", :author => @comment.author.name(community)))
  end

  def new_comment_to_followed_listing_notification(comment, recipient, community)
    set_up_urls(recipient, community)
    @comment = comment
    premailer_mail(:to => @recipient.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :subject => t("emails.new_comment.listing_you_follow_has_a_new_comment", :author => @comment.author.name(community)))
  end

  def new_update_to_followed_listing_notification(listing, recipient, community)
    set_up_urls(recipient, community)
    @listing = listing
    premailer_mail(:to => @recipient.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :subject => t("emails.new_update_to_listing.listing_you_follow_has_been_updated"))
  end

  def new_listing_by_followed_person(listing, recipient, community)
    set_up_urls(recipient, community)
    @listing = listing
    @no_recipient_name = true
    @author_name = listing.author.name(community)
    @listing_url = listing_url(@url_params.merge({:id => @listing.id}))
    @translate_scope = [ :emails, :new_listing_by_followed_person ]
    premailer_mail(:to => @recipient.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :subject => t("emails.new_listing_by_followed_person.subject",
                       :author_name => @author_name,
                       :community => community.full_name_with_separator(recipient.locale)))
  end

  def invitation_to_kassi(invitation)
    @invitation = invitation
    I18n.locale = @invitation.inviter.locale
    @invitation_code_required = @invitation.community.join_with_invite_only
    set_up_urls(nil, @invitation.community)
    @url_params[:locale] = @invitation.inviter.locale
    subject = t("emails.invitation_to_kassi.you_have_been_invited_to_kassi", :inviter => @invitation.inviter.name(@invitation.community), :community => @invitation.community.full_name_with_separator(@invitation.inviter.locale))
    premailer_mail(:to => @invitation.email,
         :from => community_specific_sender(@invitation.community),
         :subject => subject,
         :reply_to => @invitation.inviter.confirmed_notification_email_to)
  end

  # A message from the community admin to a single community member
  def community_member_email(sender, recipient, email_subject, email_content, community)
    @email_type = "email_from_admins"
    set_up_urls(recipient, community, @email_type)
    @email_content = email_content
    @no_recipient_name = true
    premailer_mail(:to => @recipient.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :subject => email_subject,
         :reply_to => "\"#{sender.name(community)}\"<#{sender.confirmed_notification_email_to}>")
  end

  # Used to send notification to Sharetribe admins when somebody
  # gives feedback on Sharetribe
  def new_feedback(feedback, community)
    subject = "New #unanswered #feedback from #{community.name(community.default_locale)} community from user #{feedback.author.try(:name)} "

    premailer_mail(
      :to => mail_feedback_to(community, APP_CONFIG.feedback_mailer_recipients),
      :from => community_specific_sender(community),
      :subject => subject,
      :reply_to => feedback.email) do |format|
        format.html {
          render locals: {
                   author_name_and_email: feedback.author_name_and_email,
                   community_name: community.name(I18n.locale),
                   content: feedback.content
                 }
      }
    end
  end

  def mail_feedback_to(community, platform_admin_email)
    if community.feedback_to_admin? && community.admin_emails.any?
      community.admin_emails.join(",")
    else
      platform_admin_email
    end
  end

  # Old layout

  def new_member_notification(person, community, email)
    @community = community
    @no_settings = true
    @person = person
    @email = email
    premailer_mail(:to => @community.admin_emails,
         :from => community_specific_sender(@community),
         :subject => "New member in #{@community.full_name(@person.locale)}")
  end

  def email_confirmation(email, community)
    @current_community = community
    @no_settings = true
    @resource = email.person
    @confirmation_token = email.confirmation_token
    @host = community.full_domain
    set_locale(email.person.locale)
    email.update_attribute(:confirmation_sent_at, Time.now)
    premailer_mail(:to => email.address,
         :from => community_specific_sender(community),
         :subject => t("devise.mailer.confirmation_instructions.subject"),
         :template_path => 'devise/mailer',
         :template_name => 'confirmation_instructions')
  end

  def reset_password_instructions(person, email_address, community)
    set_up_urls(nil, community) # Using nil as recipient, as we don't want auth token here.
    @person = person
    @no_settings = true
    premailer_mail(:to => email_address,
         :from => community_specific_sender(@community),
         :subject => t("devise.mailer.reset_password_instructions.subject")) do |format|
       format.html { render :layout => false }
     end
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

    premailer_mail(:to => recipient.confirmed_notification_emails_to, :subject => subject, :reply_to => "diego@sharetribe.com", :delivery_method => delivery_method)
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

    premailer_mail(:to => @recipient.confirmed_notification_emails_to, :subject => @subject) do |format|
      format.text { render :layout => false }
    end
  end

  def self.deliver_open_content_messages(people_array, subject, mail_content, default_locale="en", verbose=false, addresses_to_skip=[])
    people_array.each do |person|
      # only send mail to people whose profile is active and not asked to be skipped
      if person.active && ! person.confirmed_notification_emails.any? { |notification_email| addresses_to_skip.include?(notification_email) }
        begin
          PersonMailer.open_content_message(person, subject, mail_content, default_locale).deliver
        rescue => e
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

  def welcome_email(person, community, regular_email=nil, test_email=false)
    @recipient = person
    set_locale @recipient.locale
    @current_community = community
    @regular_email = regular_email
    @url_params = {}
    @url_params[:host] = "#{@current_community.full_domain}"
    @url_params[:locale] = @recipient.locale
    @url_params[:ref] = "welcome_email"
    @url_params.freeze # to avoid accidental modifications later
    @test_email = test_email

    if @recipient.has_admin_rights_in?(@current_community) && !@test_email
      subject = t("emails.welcome_email.welcome_email_subject_for_marketplace_creator")
    else
      subject = t("emails.welcome_email.welcome_email_subject", :community => @current_community.full_name(@recipient.locale), :person => person.given_name_or_username)
    end
    premailer_mail(:to => @recipient.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :subject => subject) do |format|
      format.html { render :layout => 'email_blank_layout' }
    end
  end

  # Depricated. Use CreateMemberEmailBatchJob instead.
  # A message from the community admin to all the community members
  def self.community_member_emails(sender, community, email_subject, email_content, email_locale)
    community.members.each do |recipient|
      self.community_member_email_from_admin(sender, recipient, community, email_subject, email_content, email_locale)
    end
  end

  # A message from the community admin to a community member
  def self.community_member_email_from_admin(sender, recipient, community, email_subject, email_content, email_locale)
    if recipient.should_receive?("email_from_admins") && (email_locale.eql?("any") || recipient.locale.eql?(email_locale))
      begin
        community_member_email(sender, recipient, email_subject, email_content, community).deliver
      rescue => e
        # Catch the exception and continue sending the emails
        ApplicationHelper.send_error_notification("Error sending email to all the members of community #{community.full_name(email_locale)}: #{e.message}", e.class)
      end
    end
  end

  def premailer_mail(opts, &block)
    premailer(mail(opts, &block))
  end

  # This is an ugly method. Ideas how to improve are very welcome.
  # Depending on a class name prevents refactoring.
  def payment_url(conversation, recipient, url_params)
    if conversation.payment.is_a? BraintreePayment
      edit_person_message_braintree_payment_url(url_params.merge({:id => conversation.payment.id, :person_id => recipient.id.to_s, :message_id => conversation.id}))
    else
      new_person_message_payment_url(recipient, url_params.merge({:message_id => conversation.id}))
    end
  end
end
