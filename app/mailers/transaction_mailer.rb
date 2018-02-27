# Transaction mailer
#
# Responsible for:
# - transactions created
# - transaction status changes
# - reminders
#

include ApplicationHelper
include ListingsHelper

class TransactionMailer < ActionMailer::Base
  include MailUtils

  default :from => APP_CONFIG.sharetribe_mail_from_address
  layout 'email'

  add_template_helper(EmailTemplateHelper)

  def transaction_preauthorized(transaction)
    @transaction = transaction
    @community = transaction.community

    recipient = transaction.author
    set_up_layout_variables(recipient, transaction.community)
    with_locale(recipient.locale, transaction.community.locales.map(&:to_sym), transaction.community.id) do

      payment_type = transaction.payment_gateway.to_sym
      gateway_expires = TransactionService::Transaction.authorization_expiration_period(payment_type)

      expires = Maybe(transaction).booking.end_on.map { |booking_end|
        TransactionService::Transaction.preauth_expires_at(gateway_expires.days.from_now, booking_end)
      }.or_else(gateway_expires.days.from_now)

      buffer = 1.minute # Add a small buffer (it might take a couple seconds until the email is sent)
      expires_in = TimeUtils.time_to(expires + buffer)

      premailer_mail(
        mail_params(
          @recipient,
          @community,
          t("emails.transaction_preauthorized.subject", requester: PersonViewUtils.person_display_name(transaction.starter, @community), listing_title: transaction.listing.title))) do |format|
        format.html {
          render locals: {
                   payment_expires_in_unit: expires_in[:unit],
                   payment_expires_in_count: expires_in[:count]
                 }
        }
      end
    end
  end

  def transaction_preauthorized_reminder(transaction)
    @transaction = transaction
    @community = transaction.community

    recipient = transaction.author
    set_up_layout_variables(recipient, transaction.community)
    with_locale(recipient.locale, transaction.community.locales.map(&:to_sym), transaction.community.id) do

      premailer_mail(
        mail_params(
          @recipient,
          @community,
          t("emails.transaction_preauthorized_reminder.subject", requester: transaction.starter.name(@community), listing_title: transaction.listing.title)))
    end
  end

  # seller_model, buyer_model and community can be passed as params for testing purposes
  def payment_receipt_to_seller(transaction, seller_model = nil, buyer_model = nil, community = nil)
    seller_model ||= Person.find(transaction.listing_author_id)
    buyer_model ||= Person.find(transaction.starter_id)
    community ||= Community.find(transaction.community_id)

    payment = TransactionService::Transaction.payment_details(transaction)
    payment_total = payment[:payment_total]
    service_fee = Maybe(payment[:charged_commission]).or_else(Money.new(0, payment_total.currency))
    gateway_fee = payment[:payment_gateway_fee]

    prepare_template(community, seller_model, "email_about_new_payments")
    with_locale(seller_model.locale, community.locales.map(&:to_sym), community.id) do

      you_get = payment_total - service_fee - gateway_fee

      unit_type = Maybe(transaction).select { |t| t[:unit_type].present? }.map { |t| ListingViewUtils.translate_unit(t[:unit_type], t[:unit_tr_key]) }.or_else(nil)
      quantity_selector_label = Maybe(transaction).select { |t| t[:unit_type].present? }.map { |t| ListingViewUtils.translate_quantity(t[:unit_type], t[:unit_selector_tr_key]) }.or_else(nil)
      listing_title = if transaction.booking.try(:per_hour?)
        t("emails.new_payment.listing_per_unit_title", title: transaction.listing_title, unit_type: unit_type)
      else
        transaction.listing_title
      end

      premailer_mail(:to => seller_model.confirmed_notification_emails_to,
                     :from => community_specific_sender(community),
                     :subject => t("emails.new_payment.new_payment")) do |format|
        format.html {
          render "payment_receipt_to_seller", locals: {
                   conversation_url: person_transaction_url(seller_model, @url_params.merge(id: transaction.id)),
                   listing_title: listing_title,
                   price_per_unit_title: t("emails.new_payment.price_per_unit_type", unit_type: unit_type),
                   quantity_selector_label: quantity_selector_label,
                   listing_price: MoneyViewUtils.to_humanized(transaction.unit_price),
                   listing_quantity: transaction.listing_quantity,
                   duration: transaction.booking.present? ? transaction.listing_quantity: nil,
                   subtotal: MoneyViewUtils.to_humanized(transaction.item_total),
                   payment_total: MoneyViewUtils.to_humanized(payment_total),
                   shipping_total: MoneyViewUtils.to_humanized(transaction.shipping_price),
                   payment_service_fee: MoneyViewUtils.to_humanized(-service_fee),
                   payment_gateway_fee: MoneyViewUtils.to_humanized(-gateway_fee),
                   payment_seller_gets: MoneyViewUtils.to_humanized(you_get),
                   payer_full_name: buyer_model.name(community),
                   payer_given_name: PersonViewUtils.person_display_name_for_type(buyer_model, "first_name_only"),
                   gateway: transaction.payment_gateway,
                   community_name: community.name_with_separator(seller_model.locale),
                 }
        }
      end
    end
  end

  # seller_model, buyer_model and community can be passed as params for testing purposes
  def payment_receipt_to_buyer(transaction, seller_model = nil, buyer_model = nil, community = nil)
    seller_model ||= Person.find(transaction.listing_author_id)
    buyer_model ||= Person.find(transaction.starter_id)
    community ||= Community.find(transaction.community_id)
    payment = TransactionService::Transaction.payment_details(transaction)

    prepare_template(community, buyer_model, "email_about_new_payments")
    with_locale(buyer_model.locale, community.locales.map(&:to_sym), community.id) do

      unit_type = Maybe(transaction).select { |t| t[:unit_type].present? }.map { |t| ListingViewUtils.translate_unit(t[:unit_type], t[:unit_tr_key]) }.or_else(nil)
      quantity_selector_label = Maybe(transaction).select { |t| t[:unit_type].present? }.map { |t| ListingViewUtils.translate_quantity(t[:unit_type], t[:unit_selector_tr_key]) }.or_else(nil)
      listing_title = if transaction.booking.try(:per_hour?)
        t("emails.receipt_to_payer.listing_per_unit_title", title: transaction.listing_title, unit_type: unit_type)
      else
        transaction.listing_title
      end

      premailer_mail(:to => buyer_model.confirmed_notification_emails_to,
                     :from => community_specific_sender(community),
                     :subject => t("emails.receipt_to_payer.receipt_of_payment")) { |format|
        format.html {
          render "payment_receipt_to_buyer", locals: {
                   conversation_url: person_transaction_url(buyer_model, @url_params.merge({:id => transaction.id})),
                   listing_title: listing_title,
                   price_per_unit_title: t("emails.receipt_to_payer.price_per_unit_type", unit_type: unit_type),
                   quantity_selector_label: quantity_selector_label,
                   listing_price: MoneyViewUtils.to_humanized(transaction.unit_price),
                   listing_quantity: transaction.listing_quantity,
                   duration: transaction.booking.present? ? transaction.listing_quantity : nil,
                   subtotal: MoneyViewUtils.to_humanized(transaction.item_total),
                   shipping_total: MoneyViewUtils.to_humanized(transaction.shipping_price),
                   payment_total: MoneyViewUtils.to_humanized(payment[:payment_total]),
                   recipient_full_name: seller_model.name(community),
                   recipient_given_name: PersonViewUtils.person_display_name_for_type(seller_model, "first_name_only"),
                   automatic_confirmation_days: nil,
                   show_money_will_be_transferred_note: false,
                   gateway: transaction.payment_gateway,
                   community_name: community.name_with_separator(buyer_model.locale),
                 }
        }
      }
    end
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
    @show_branding_info = !PlanService::API::Api.plans.get_current(community_id: community.id).data[:features][:whitelabel]
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
