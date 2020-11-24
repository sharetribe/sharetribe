# Transaction mailer
#
# Responsible for:
# - transactions created
# - transaction status changes
# - reminders
#
# rubocop:disable Style/MixinUsage
include ApplicationHelper
include ListingsHelper
# rubocop:enable Style/MixinUsage

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

      mail(
        mail_params(
          @recipient,
          @community,
          t("emails.transaction_preauthorized.subject", requester: PersonViewUtils.person_display_name(transaction.starter, @community), listing_title: transaction.listing.title))) do |format|
        format.html {
          render v2_template(@community.id, 'transaction_preauthorized'),
                 locals: {
                   payment_expires_in_unit: expires_in[:unit],
                   payment_expires_in_count: expires_in[:count]
                 },
                 layout: v2_layout(@community.id)
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

      mail(
        mail_params(
          @recipient,
          @community,
          t("emails.transaction_preauthorized_reminder.subject", requester: transaction.starter.name(@community), listing_title: transaction.listing.title))) do |format|
            format.html { render v2_template(@community.id, 'transaction_preauthorized_reminder'), layout: v2_layout(@community.id) }
      end
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
    buyer_service_fee = payment[:buyer_commission] || Money.new(0, payment_total.currency)
    gateway_fee = payment[:payment_gateway_fee]
    shipping_price = Money.new(transaction.shipping_price_cents, payment_total.currency)
    subtotal = payment_total - buyer_service_fee - shipping_price
    total = payment_total
    total -= buyer_service_fee if buyer_service_fee > 0


    prepare_template(community, seller_model, "email_about_new_payments")
    with_locale(seller_model.locale, community.locales.map(&:to_sym), community.id) do

      you_get = payment_total - service_fee - gateway_fee - buyer_service_fee
      MoneyViewUtils.to_humanized(-1 * Money.new(payment[:buyer_commission], payment_total.currency))

      unit_type = Maybe(transaction).select { |t| t[:unit_type].present? }.map { |t| ListingViewUtils.translate_unit(t[:unit_type], t[:unit_tr_key]) }.or_else(nil)
      quantity_selector_label = Maybe(transaction).select { |t| t[:unit_type].present? }.map { |t| ListingViewUtils.translate_quantity(t[:unit_type], t[:unit_selector_tr_key]) }.or_else(nil)
      listing_title = if transaction.booking.try(:per_hour?)
        t("emails.new_payment.listing_per_unit_title", title: transaction.listing_title, unit_type: unit_type)
      else
        transaction.listing_title
      end

      mail(:to => seller_model.confirmed_notification_emails_to,
           :from => community_specific_sender(community),
           :subject => t("emails.new_payment.new_payment")) { |format|
        format.html {
          render v2_template(community.id, "payment_receipt_to_seller"),
                 locals: {
                   conversation_url: person_transaction_url(seller_model, @url_params.merge(id: transaction.id)),
                   listing_title: listing_title,
                   listing_info_url: listing_url(@url_params.merge(id: transaction.listing_id)),
                   price_per_unit_title: t("emails.new_payment.price_per_unit_type", unit_type: unit_type),
                   quantity_selector_label: quantity_selector_label,
                   listing_price: MoneyViewUtils.to_humanized(transaction.unit_price),
                   listing_quantity: transaction.listing_quantity,
                   duration: transaction.booking.present? ? transaction.listing_quantity: nil,
                   subtotal: MoneyViewUtils.to_humanized(subtotal),
                   payment_total: MoneyViewUtils.to_humanized(total),
                   shipping_total: MoneyViewUtils.to_humanized(transaction.shipping_price),
                   payment_service_fee: MoneyViewUtils.to_humanized(-service_fee),
                   payment_buyer_service_fee: buyer_service_fee > 0 ? MoneyViewUtils.to_humanized(-1 * buyer_service_fee) : nil,
                   payment_gateway_fee: MoneyViewUtils.to_humanized(-gateway_fee),
                   payment_seller_gets: MoneyViewUtils.to_humanized(you_get),
                   payer_full_name: buyer_model.name(community),
                   payer_given_name: PersonViewUtils.person_display_name_for_type(buyer_model, "first_name_only"),
                   gateway: transaction.payment_gateway,
                   community_name: community.name_with_separator(seller_model.locale)
                 },
                 layout: v2_layout(community.id)
        }
      }
    end
  end

  # seller_model, buyer_model and community can be passed as params for testing purposes
  def payment_receipt_to_buyer(transaction, seller_model = nil, buyer_model = nil, community = nil)
    seller_model ||= Person.find(transaction.listing_author_id)
    buyer_model ||= Person.find(transaction.starter_id)
    community ||= Community.find(transaction.community_id)
    payment = TransactionService::Transaction.payment_details(transaction)
    buyer_service_fee = if payment[:buyer_commission] && payment[:buyer_commission] > 0
                          MoneyViewUtils.to_humanized(Money.new(payment[:buyer_commission], payment[:payment_total].currency))
                        end

    prepare_template(community, buyer_model, "email_about_new_payments")
    with_locale(buyer_model.locale, community.locales.map(&:to_sym), community.id) do

      unit_type = Maybe(transaction).select { |t| t[:unit_type].present? }.map { |t| ListingViewUtils.translate_unit(t[:unit_type], t[:unit_tr_key]) }.or_else(nil)
      quantity_selector_label = Maybe(transaction).select { |t| t[:unit_type].present? }.map { |t| ListingViewUtils.translate_quantity(t[:unit_type], t[:unit_selector_tr_key]) }.or_else(nil)
      listing_title = if transaction.booking.try(:per_hour?)
        t("emails.receipt_to_payer.listing_per_unit_title", title: transaction.listing_title, unit_type: unit_type)
      else
        transaction.listing_title
      end

      mail(:to => buyer_model.confirmed_notification_emails_to,
           :from => community_specific_sender(community),
           :subject => t("emails.receipt_to_payer.receipt_of_payment")) { |format|
        format.html {
          render v2_template(community.id, "payment_receipt_to_buyer"),
                 locals: {
                   conversation_url: person_transaction_url(buyer_model, @url_params.merge({:id => transaction.id})),
                   listing_title: listing_title,
                   listing_info_url: listing_url(@url_params.merge(id: transaction.listing_id)),
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
                   payment_buyer_service_fee: buyer_service_fee
                 },
                 layout: v2_layout(community.id)
        }
      }
    end
  end

  def new_transaction(transaction, recipient)
    @transaction = transaction
    community = transaction.community
    set_up_layout_variables(recipient, community)
    with_locale(recipient.locale, community.locales.map(&:to_sym), community.id) do
      @community_name = community.full_name(recipient.locale)
      @skip_unsubscribe_footer = true
      mail(to: recipient.confirmed_notification_emails_to,
           from: community_specific_sender(community),
           subject: t("emails.new_transaction.subject")) do |format|
             format.html { render v2_template(community.id, 'new_transaction'), layout: v2_layout(community.id) }
      end
    end
  end

  def transaction_disputed(transaction:, recipient:, is_admin: false, is_seller: false)
    @transaction = transaction
    @is_admin = is_admin
    @is_seller = is_seller
    community = transaction.community
    set_up_layout_variables(recipient, community)
    with_locale(recipient.locale, community.locales.map(&:to_sym), community.id) do
      @community_name = community.full_name(recipient.locale)
      @skip_unsubscribe_footer = true
      subject_key = is_admin ? 'subject_admin' : 'subject'
      mail(to: recipient.confirmed_notification_emails_to,
           from: community_specific_sender(community),
           subject: t("emails.transaction_disputed.#{subject_key}")) do |format|
             format.html { render v2_template(community.id, 'transaction_disputed'), layout: v2_layout(community.id) }
      end
    end

  end

  def transaction_refunded(transaction:, recipient:)
    @transaction = transaction
    @is_seller = transaction.author == recipient
    community = transaction.community
    set_up_layout_variables(recipient, community)
    with_locale(recipient.locale, community.locales.map(&:to_sym), community.id) do
      @community_name = community.full_name(recipient.locale)
      @skip_unsubscribe_footer = true
      buyer = PersonViewUtils.person_display_name(transaction.starter, community)
      mail(to: recipient.confirmed_notification_emails_to,
           from: community_specific_sender(community),
           subject: t("emails.transaction_refunded.subject", buyer: buyer)) do |format|
             format.html { render v2_template(community.id, 'transaction_refunded'), layout: v2_layout(community.id) }
      end
    end

  end

  def transaction_cancellation_dismissed(transaction:, recipient:)
    @transaction = transaction
    @is_seller = transaction.author == recipient
    community = transaction.community
    set_up_layout_variables(recipient, community)
    with_locale(recipient.locale, community.locales.map(&:to_sym), community.id) do
      @community_name = community.full_name(recipient.locale)
      @skip_unsubscribe_footer = true
      buyer = PersonViewUtils.person_display_name(transaction.starter, community)
      mail(to: recipient.confirmed_notification_emails_to,
           from: community_specific_sender(community),
           subject: t("emails.transaction_cancellation_dismissed.subject", buyer: buyer)) do |format|
             format.html { render v2_template(community.id, 'transaction_cancellation_dismissed'), layout: v2_layout(community.id) }
      end
    end
  end

  def transaction_commission_charge_failed(transaction:, recipient:)
    @transaction = transaction
    community = transaction.community
    set_up_layout_variables(recipient, community)
    with_locale(recipient.locale, community.locales.map(&:to_sym), community.id) do
      @community_name = community.full_name(recipient.locale)
      @skip_unsubscribe_footer = true
      @seller = PersonViewUtils.person_display_name(transaction.listing_author, community)
      mail(to: recipient.confirmed_notification_emails_to,
           from: community_specific_sender(community),
           subject: t("emails.transaction_commission_charge_failed.subject")) do |format|
             format.html { render v2_template(community.id, 'transaction_commission_charge_failed'), layout: v2_layout(community.id) }
      end
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
end
