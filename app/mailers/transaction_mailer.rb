# Transaction mailer
#
# Responsible for:
# - transaction status changes
# - reminders
#
class TransactionMailer < ActionMailer::Base
  include Util::MailUtils

  default :from => APP_CONFIG.sharetribe_mail_from_address
  layout 'email'

  add_template_helper(EmailTemplateHelper)

  def transaction_preauthorized(conversation)
    @conversation = conversation
    @community = conversation.community

    set_up_urls(conversation.author, conversation.community)

    premailer_mail(:to => conversation.author.confirmed_notification_emails_to,
         :from => community_specific_sender(conversation.community),
         :subject => t("emails.transaction_preauthorized.subject", requester: conversation.starter.name, listing_title: conversation.listing.title))
  end

  def transaction_preauthorized_reminder(conversation)
    @conversation = conversation
    @community = conversation.community

    set_up_urls(conversation.author, conversation.community)

    premailer_mail(:to => conversation.author.confirmed_notification_emails_to,
         :from => community_specific_sender(conversation.community),
         :subject => t("emails.transaction_preauthorized_reminder.subject", requester: conversation.starter.name, listing_title: conversation.listing.title))
  end

  def premailer_mail(opts, &block)
    premailer(mail(opts, &block))
  end
end