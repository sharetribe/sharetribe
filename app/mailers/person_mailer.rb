# encoding: utf-8

include ApplicationHelper
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
    recipient = transaction.other_party(transaction.listing.author)
    set_up_layout_variables(recipient, community, @email_type)
    with_locale(recipient.locale, community.locales.map(&:to_sym), community.id) do
      @transaction = transaction

      premailer_mail(:to => recipient.confirmed_notification_emails_to,
                     :from => community_specific_sender(community),
                     :subject => t("emails.conversation_status_changed.your_request_was_#{transaction.status}"))
    end
  end

  def new_message_notification(message, community)
    @email_type =  "email_about_new_messages"
    recipient = message.conversation.other_party(message.sender)
    set_up_layout_variables(recipient, community, @email_type)
    with_locale(recipient.locale, community.locales.map(&:to_sym), community.id) do
      @message = message
      sending_params = {:to => recipient.confirmed_notification_emails_to,
                        :subject => t("emails.new_message.you_have_a_new_message", :sender_name => PersonViewUtils.person_display_name(message.sender, community)),
                        :from => community_specific_sender(community)}

      premailer_mail(sending_params)
    end
  end

  def transaction_confirmed(conversation, community)
    @email_type =  "email_about_completed_transactions"
    @conversation = conversation
    recipient = conversation.seller
    set_up_layout_variables(conversation.seller, community, @email_type)
    with_locale(recipient.locale, community.locales.map(&:to_sym), community.id) do
      premailer_mail(:to => recipient.confirmed_notification_emails_to,
                     :from => community_specific_sender(community),
                     :subject => t("emails.transaction_confirmed.request_marked_as_#{@conversation.status}"))
    end
  end

  def transaction_automatically_confirmed(conversation, community)
    @email_type =  "email_about_completed_transactions"
    @conversation = conversation
    recipient = conversation.buyer
    set_up_layout_variables(recipient, community, @email_type)
    with_locale(recipient.locale, community.locales.map(&:to_sym), community.id) do
      premailer_mail(:to => recipient.confirmed_notification_emails_to,
                     :from => community_specific_sender(community),
                     :template_path => 'person_mailer/automatic_confirmation',
                     :subject => t("emails.transaction_automatically_confirmed.subject"))
    end
  end

  def booking_transaction_automatically_confirmed(transaction, community)
    @email_type = "email_about_completed_transactions"
    @transaction = transaction
    recipient = @transaction.buyer
    set_up_layout_variables(recipient, community, @email_type)
    with_locale(recipient.locale, community.locales.map(&:to_sym), community.id) do
      mail(:to => @recipient.confirmed_notification_emails_to,
           :from => community_specific_sender(community),
           :template_path => 'person_mailer/automatic_confirmation',
           :subject => t("emails.booking_transaction_automatically_confirmed.subject"))
    end
  end

  def new_testimonial(testimonial, community)
    @email_type =  "email_about_new_received_testimonials"
    recipient = testimonial.receiver
    set_up_layout_variables(recipient, community, @email_type)
    with_locale(recipient.locale, community.locales.map(&:to_sym), community.id) do
      @testimonial = testimonial
      @wating_testimonial = @testimonial.tx.waiting_testimonial_from?(@testimonial.receiver.id)
      premailer_mail(:to => recipient.confirmed_notification_emails_to,
                     :from => community_specific_sender(community),
                     :subject => t("emails.new_testimonial.has_given_you_feedback_in_kassi", :name => PersonViewUtils.person_display_name(testimonial.author, community)))
    end
  end

  # Remind user to fill in payment details
  def payment_settings_reminder(listing, recipient, community)
    set_up_layout_variables(recipient, community)
    with_locale(recipient.locale, community.locales.map(&:to_sym), community.id) do
      @listing = listing
      @recipient = recipient

      if community.payments_in_use?
        @payment_settings_link = paypal_account_settings_payment_url(recipient, @url_params.merge(locale: recipient.locale))
      end

      premailer_mail(:to => recipient.confirmed_notification_emails_to,
                     :from => community_specific_sender(community),
                     :subject => t("emails.payment_settings_reminder.remember_to_add_payment_details")) do |format|
        format.html {render :locals => {:skip_unsubscribe_footer => true} }
      end
    end
  end

  # Remind users of conversations that have not been accepted or rejected
  def confirm_reminder(conversation, recipient, community, days_to_cancel)
    @email_type = "email_about_confirm_reminders"
    recipient = conversation.buyer
    set_up_layout_variables(recipient, community, @email_type)
    with_locale(recipient.locale, community.locales.map(&:to_sym), community.id) do
      @conversation = conversation
      @days_to_cancel = days_to_cancel
      template = "confirm_reminder"
      premailer_mail(:to => recipient.confirmed_notification_emails_to,
                     :from => community_specific_sender(community),
                     :subject => t("emails.confirm_reminder.remember_to_confirm_request")) do |format|
        format.html { render template }
      end
    end
  end

  # Remind users to give feedback
  def testimonial_reminder(conversation, recipient, community)
    @email_type = "email_about_testimonial_reminders"
    set_up_layout_variables(recipient, community, @email_type)
    with_locale(recipient.locale, community.locales.map(&:to_sym), community.id) do
      @conversation = conversation
      @other_party = @conversation.other_party(recipient)
      premailer_mail(:to => recipient.confirmed_notification_emails_to,
                     :from => community_specific_sender(community),
                     :subject => t("emails.testimonial_reminder.remember_to_give_feedback_to", :name => PersonViewUtils.person_display_name(@other_party, community)))
    end
  end

  def new_comment_to_own_listing_notification(comment, community)
    @email_type = "email_about_new_comments_to_own_listing"
    recipient = comment.listing.author
    set_up_layout_variables(recipient, community, @email_type)
    with_locale(recipient.locale, community.locales.map(&:to_sym), community.id) do
      @comment = comment
      premailer_mail(:to => recipient.confirmed_notification_emails_to,
                     :from => community_specific_sender(community),
                     :subject => t("emails.new_comment.you_have_a_new_comment", :author => PersonViewUtils.person_display_name(comment.author, community)))
    end
  end

  def new_comment_to_followed_listing_notification(comment, recipient, community)
    set_up_layout_variables(recipient, community)
    with_locale(recipient.locale, community.locales.map(&:to_sym), community.id) do
      @comment = comment
      premailer_mail(:to => recipient.confirmed_notification_emails_to,
                     :from => community_specific_sender(community),
                     :subject => t("emails.new_comment.listing_you_follow_has_a_new_comment", :author => PersonViewUtils.person_display_name(comment.author, community)))
    end
  end

  def new_update_to_followed_listing_notification(listing, recipient, community)
    set_up_layout_variables(recipient, community)
    with_locale(recipient.locale, community.locales.map(&:to_sym), community.id) do
      @listing = listing
      premailer_mail(:to => recipient.confirmed_notification_emails_to,
                     :from => community_specific_sender(community),
                     :subject => t("emails.new_update_to_listing.listing_you_follow_has_been_updated"))
    end
  end

  def new_listing_by_followed_person(listing, recipient, community)
    set_up_layout_variables(recipient, community)
    with_locale(recipient.locale, community.locales.map(&:to_sym), community.id) do
      @listing = listing
      @no_recipient_name = true
      @author_name = PersonViewUtils.person_display_name(listing.author, community)
      @listing_url = listing_url(@url_params.merge({:id => listing.id}))
      @translate_scope = [ :emails, :new_listing_by_followed_person ]
      premailer_mail(:to => recipient.confirmed_notification_emails_to,
                     :from => community_specific_sender(community),
                     :subject => t("emails.new_listing_by_followed_person.subject",
                                   :author_name => @author_name,
                                   :community => community.full_name_with_separator(recipient.locale)))
    end
  end

  def invitation_to_kassi(invitation)
    @invitation = invitation
    mail_locale = @invitation.inviter.locale
    @invitation_code_required = invitation.community.join_with_invite_only
    set_up_layout_variables(nil, invitation.community)
    @url_params[:locale] = mail_locale
    @url_params[:code] = invitation.code
    @invitation_community = invitation.community.full_name_with_separator(invitation.inviter.locale)
    with_locale(mail_locale, invitation.community.locales.map(&:to_sym), invitation.community.id) do
      subject = t("emails.invitation_to_kassi.you_have_been_invited_to_kassi", :inviter => PersonViewUtils.person_display_name(invitation.inviter, invitation.community), :community => @invitation_community)
      premailer_mail(:to => invitation.email,
                     :from => community_specific_sender(invitation.community),
                     :subject => subject,
                     :reply_to => invitation.inviter.confirmed_notification_email_to)
    end
  end

  # A message from the community admin to a single community member
  def community_member_email(sender, recipient, email_subject, email_content, community)
    @email_type = "email_from_admins"
    set_up_layout_variables(recipient, community, @email_type)

    sender_address = EmailService::API::Api.addresses.get_sender(community_id: community.id).data
    if sender_address[:type] == :default
      sender_name = sender.name(community)
      sender_email = sender.confirmed_notification_email_to
      reply_to = "\"#{sender_name}\"<#{sender_email}>"
    else
      reply_to = sender_address[:smtp_format]
    end

    with_locale(recipient.locale, community.locales.map(&:to_sym), community.id) do
      @email_content = email_content
      @no_recipient_name = true
      premailer_mail(:to => recipient.confirmed_notification_emails_to,
                     :from => community_specific_sender(community),
                     :subject => email_subject,
                     :reply_to => reply_to)
    end
  end

  # Used to send notification to marketplace admins when somebody
  # gives feedback on marketplace throught the contact us button in menu
  def new_feedback(feedback, community)
    subject = t("feedback.feedback_subject", service_name: community.name(I18n.locale))

    premailer_mail(
      :to => mail_feedback_to(community, APP_CONFIG.feedback_mailer_recipients),
      :from => community_specific_sender(community),
      :subject => subject,
      :reply_to => feedback.email) do |format|
        format.html {
          render locals: {
                   author_name_and_email: feedback_author_name_and_email(feedback.author, feedback.email, community),
                   community_name: community.name(I18n.locale),
                   content: feedback.content
                 }
      }
    end
  end

  def mail_feedback_to(community, platform_admin_email)
    if community.admin_emails.any?
      community.admin_emails.join(",")
    else
      platform_admin_email
    end
  end

  # Old layout

  def new_member_notification(new_member, community, admin)
    @community = community
    @no_settings = true
    @person = new_member
    @email = new_member.emails.last.address
    with_locale(admin.locale, community.locales.map(&:to_sym), community.id) do
      address = admin.confirmed_notification_emails_to
      if address.present?
        premailer_mail(:to => address,
                       :from => community_specific_sender(community),
                       :subject => "New member in #{@community.full_name(@person.locale)}",
                       :template_name => "new_member_notification")
      end
    end
  end

  def email_confirmation(email, community)
    @current_community = community
    @no_settings = true
    @resource = email.person
    @confirmation_token = email.confirmation_token
    @host = community.full_domain
    @show_branding_info = !PlanService::API::Api.plans.get_current(community_id: community.id).data[:features][:whitelabel]
    with_locale(email.person.locale, community.locales.map(&:to_sym), community.id) do
      email.update_attribute(:confirmation_sent_at, Time.now)
      premailer_mail(:to => email.address,
                     :from => community_specific_sender(community),
                     :subject => t("devise.mailer.confirmation_instructions.subject"),
                     :template_path => 'devise/mailer',
                     :template_name => 'confirmation_instructions')
    end
  end

  def reset_password_instructions(person, email_address, reset_token, community)
    set_up_layout_variables(nil, community) # Using nil as recipient, as we don't want auth token here.
    @person = person
    @no_settings = true
    premailer_mail(
         to: email_address,
         from: community_specific_sender(@community),
         subject: t("devise.mailer.reset_password_instructions.subject")) do |format|
      format.html {
        render layout: false, locals: { reset_token: reset_token,
                                        host: @community.full_domain}
      }
     end
  end

  def welcome_email(person, community, regular_email=nil, test_email=false)
    @recipient = person
    recipient = person
    with_locale(recipient.locale, community.locales.map(&:to_sym), community.id) do

      @current_community = community

      @regular_email = regular_email
      @url_params = {}
      @url_params[:host] = "#{community.full_domain}"
      @url_params[:locale] = recipient.locale
      @url_params[:ref] = "welcome_email"
      @url_params.freeze # to avoid accidental modifications later
      @test_email = test_email
      @show_branding_info = !PlanService::API::Api.plans.get_current(community_id: community.id).data[:features][:whitelabel]

      subject = if @recipient.has_admin_rights?(@current_community) && !@test_email
        t("emails.welcome_email_marketplace_creator.welcome_email_subject_for_marketplace_creator")
      else
        t("emails.welcome_email.welcome_email_subject", :community => community.full_name(recipient.locale), :person => PersonViewUtils.person_display_name_for_type(person, "first_name_only"))
      end
      premailer_mail(:to => recipient.confirmed_notification_emails_to,
                     :from => community_specific_sender(community),
                     :subject => subject) do |format|
        format.html { render :layout => 'email_blank_layout' }
      end
    end
  end

  # A message from the community admin to a community member
  def self.community_member_email_from_admin(sender, recipient, community, email_content, email_locale, test = false)
    if recipient.should_receive?("email_from_admins") && (email_locale.eql?("any") || recipient.locale.eql?(email_locale))
      subject = I18n.t('admin.emails.new.email_subject_text',
                       :service_name => community.name(email_locale), :locale => recipient.locale)
      subject = "[TEST] #{subject}" if test
      content_hello = I18n.t('admin.emails.new.hello_firstname_text',
                             :person => PersonViewUtils.person_display_name_for_type(recipient, "first_name_only"),
                             :locale => recipient.locale)
      content = "#{content_hello}<BR />\n #{email_content}"
      begin
        MailCarrier.deliver_now(community_member_email(sender, recipient, subject, content, community))
      rescue => e
        # Catch the exception and continue sending the emails
        ApplicationHelper.send_error_notification("Error sending email to all the members of community #{community.full_name(email_locale)}: #{e.message}", e.class)
      end
    end
  end

  def premailer_mail(opts, &block)
    premailer(mail(opts, &block))
  end

  private

  def feedback_author_name_and_email(author, email, community)
    present = ->(x) {x.present?}
      case [author, email]
      when matches([present, present])
        "#{PersonViewUtils.person_display_name(author, community)} (#{email})"
      when matches([nil, present])
        "#{t("feedback.unlogged_user")} (#{email})"
      else
        "#{t("feedback.anonymous_user")}"
      end
  end
end
