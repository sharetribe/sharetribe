# Transaction mailer
#
# Responsible for:
# - transactions created
# - transaction status changes
# - reminders
#
class TransactionMailer < ActionMailer::Base
  include MailUtils

  default :from => APP_CONFIG.sharetribe_mail_from_address
  layout 'email'

  add_template_helper(EmailTemplateHelper)

  def transaction_created(transaction)
    community = transaction.community

    recipient = transaction.author
    sender = transaction.starter
    sender_name = sender.name(community)

    url_params = build_url_params(community, recipient)
    reply_url = person_transaction_url(recipient, url_params.merge(:id => transaction.id))

    prepare_template(community, recipient)

    # TODO Now that we have splitted "new message", we could be more specific here, and say that this message
    # is about a new transaction!
    premailer_mail(
      mail_params(recipient, community, t("emails.new_message.you_have_a_new_message", :sender_name => sender_name))) do |format|
        format.html {
          render locals: {
            recipient: recipient,
            reply_url: reply_url,
            sender_name: sender_name,
          }
        }
    end
  end

  def transaction_preauthorized(conversation)
    @conversation = conversation
    @community = conversation.community

    set_up_urls(conversation.author, conversation.community)

    payment_type = MarketplaceService::Community::Query.payment_type(@community.id)
    gateway_expires = MarketplaceService::Transaction::Entity.authorization_expiration_period(payment_type)

    premailer_mail(
      mail_params(
        @recipient,
        @community,
        t("emails.transaction_preauthorized.subject", requester: conversation.starter.name, listing_title: conversation.listing.title))) do |format|
      format.html {
        render locals: {
          payment_expires_in_days: gateway_expires
        }
      }
    end
  end

  def transaction_preauthorized_reminder(conversation)
    @conversation = conversation
    @community = conversation.community

    set_up_urls(conversation.author, conversation.community)

    premailer_mail(
      mail_params(
        @recipient,
        @community,
        t("emails.transaction_preauthorized_reminder.subject", requester: conversation.starter.name, listing_title: conversation.listing.title)))
  end

  private

  def premailer_mail(opts, &block)
    premailer(mail(opts, &block))
  end

  # TODO Get rid of this method. Pass all data in local variables, not instance variables.
  def prepare_template(community, recipient)
    @community = community
    @current_community = community
    @recipient = recipient
    @url_params = build_url_params(community, recipient)
    set_locale(recipient.locale)
  end

  def mail_params(recipient, community, subject)
    {
      to: recipient.confirmed_notification_emails_to,
      from: community_specific_sender(community),
      subject: subject
    }
  end

  def build_url_params(community, recipient, ref="email")
    {
      host: community.full_domain,
      ref: ref,
      locale: recipient.locale
    }
  end

end
