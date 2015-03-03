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

  include ApplicationHelper
  include MoneyRails::ActionViewExtension # this is for humanized_money_with_symbol

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

  def transaction_preauthorized(transaction)
    @transaction = transaction
    @community = @transaction.community

    set_up_urls(@transaction.author, @transaction.community)

    payment_type = MarketplaceService::Community::Query.payment_type(@community.id)
    gateway_expires = MarketplaceService::Transaction::Entity.authorization_expiration_period(payment_type)

    premailer_mail(
      mail_params(
        @recipient,
        @community,
        t("emails.transaction_preauthorized.subject", requester: @transaction.starter.name, listing_title: @transaction.listing.title))) do |format|
      format.html {
        render locals: {
          payment_expires_in_days: gateway_expires
        }
      }
    end
  end

  def transaction_preauthorized_reminder(transaction)
    @transaction = transaction
    @community = @transaction.community

    set_up_urls(@transaction.author, @transaction.community)

    premailer_mail(
      mail_params(
        @recipient,
        @community,
        t("emails.transaction_preauthorized_reminder.subject", requester: @transaction.starter.name, listing_title: @transaction.listing.title)))
  end

  def braintree_new_payment(payment, community)
    prepare_template(community, payment.recipient, "email_about_new_payments")

    service_fee = payment.total_commission
    you_get = payment.seller_gets

    premailer_mail(:to => payment.recipient.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :subject => t("emails.new_payment.new_payment")) { |format|
      format.html {
        render "braintree_payment_receipt_to_seller", locals: {
          conversation_url: person_transaction_url(payment.recipient, @url_params.merge({:id => payment.transaction.id.to_s})),
          listing_title: payment.transaction.listing.title,
          payment_total: humanized_money_with_symbol(payment.total_sum),
          payment_service_fee: humanized_money_with_symbol(service_fee),
          payment_seller_gets: humanized_money_with_symbol(you_get),
          payer_full_name: payment.payer.name(community),
          payer_given_name: payment.payer.given_name_or_username,
          automatic_confirmation_days: payment.transaction.automatic_confirmation_after_days,
          show_money_will_be_transferred_note: true
        }
      }
    }
  end

  def braintree_receipt_to_payer(payment, community)
    prepare_template(community, payment.payer, "email_about_new_payments")

    premailer_mail(:to => payment.payer.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :subject => t("emails.receipt_to_payer.receipt_of_payment")) { |format|
      format.html {
        render "payment_receipt_to_buyer", locals: {
          conversation_url: person_transaction_url(payment.payer, @url_params.merge({:id => payment.transaction.id.to_s})),
          listing_title: payment.transaction.listing.title,
          payment_total: humanized_money_with_symbol(payment.total_sum),
          subtotal: humanized_money_with_symbol(payment.total_sum),
          shipping_total: nil,
          recipient_full_name: payment.recipient.name(community),
          recipient_given_name: payment.recipient.given_name_or_username,
          automatic_confirmation_days: payment.transaction.automatic_confirmation_after_days,
          show_money_will_be_transferred_note: true
        }
      }
    }
  end

  # seller_model, buyer_model and community can be passed as params for testing purposes
  def paypal_new_payment(transaction, seller_model = nil, buyer_model = nil, community = nil)
    seller_model ||= Person.find(transaction[:listing_author_id])
    buyer_model ||= Person.find(transaction[:starter_id])
    community ||= Community.find(transaction[:community_id])

    payment_total = transaction[:payment_total]
    subtotal = transaction[:payment_total] - Maybe(transaction[:shipping_price]).or_else(0)
    service_fee = Maybe(transaction[:charged_commission]).or_else(Money.new(0, payment_total.currency))
    shipping_total = transaction[:shipping_price]
    gateway_fee = transaction[:payment_gateway_fee]

    prepare_template(community, seller_model, "email_about_new_payments")

    you_get = payment_total - service_fee - gateway_fee

    premailer_mail(:to => seller_model.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :subject => t("emails.new_payment.new_payment")) do |format|
      format.html {
        render "paypal_payment_receipt_to_seller", locals: {
          conversation_url: person_transaction_url(seller_model, @url_params.merge(id: transaction[:id])),
          listing_title: transaction[:listing_title],
          subtotal: humanized_money_with_symbol(subtotal),
          payment_total: humanized_money_with_symbol(payment_total),
          shipping_total: humanized_money_with_symbol(shipping_total),
          payment_service_fee: humanized_money_with_symbol(service_fee),
          paypal_gateway_fee: humanized_money_with_symbol(gateway_fee),
          payment_seller_gets: humanized_money_with_symbol(you_get),
          payer_full_name: buyer_model.name(community),
          payer_given_name: buyer_model.given_name_or_username,
        }
      }
    end
  end

  # seller_model, buyer_model and community can be passed as params for testing purposes
  def paypal_receipt_to_payer(transaction, seller_model = nil, buyer_model = nil, community = nil)
    seller_model ||= Person.find(transaction[:listing_author_id])
    buyer_model ||= Person.find(transaction[:starter_id])
    community ||= Community.find(transaction[:community_id])

    prepare_template(community, buyer_model, "email_about_new_payments")

    subtotal = transaction[:payment_total] - Maybe(transaction[:shipping_price]).or_else(0)

    premailer_mail(:to => buyer_model.confirmed_notification_emails_to,
         :from => community_specific_sender(community),
         :subject => t("emails.receipt_to_payer.receipt_of_payment")) { |format|
      format.html {
        render "payment_receipt_to_buyer", locals: {
          conversation_url: person_transaction_url(buyer_model, @url_params.merge({:id => transaction[:id]})),
          listing_title: transaction[:listing_title],
          subtotal: humanized_money_with_symbol(subtotal),
          shipping_total: humanized_money_with_symbol(transaction[:shipping_price]),
          payment_total: humanized_money_with_symbol(transaction[:payment_total]),
          recipient_full_name: seller_model.name(community),
          recipient_given_name: seller_model.given_name_or_username,
          automatic_confirmation_days: nil,
          show_money_will_be_transferred_note: false
        }
      }
    }
  end

  private

  def premailer_mail(opts, &block)
    premailer(mail(opts, &block))
  end

  # TODO Get rid of this method. Pass all data in local variables, not instance variables.
  def prepare_template(community, recipient, email_type = nil)
    @email_type = email_type
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
