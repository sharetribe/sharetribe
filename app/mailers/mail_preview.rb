#require 'factory_girl'

class MailPreview < MailView
  include MailViewTestData

  def new_payment
    # instead of mock data, show last suitable payment
    payment = CheckoutPayment.last
    throw "No CheckoutPayments in DB, can't show this mail template." if payment.nil?
    community = payment.community

    PersonMailer.new_payment(payment, community)
  end

  def payment_settings_reminder
    recipient = Struct.new(:id, :given_name_or_username, :confirmed_notification_emails_to, :new_email_auth_token, :locale).new("123", "Test Recipient", "test@example.com", "123-abc", "en")
    listing = Struct.new(:id, :title).new(123, "Hammer")
    payment_gateway = Class.new()
    payment_gateway.define_singleton_method(:settings_url) { |*args| "http://marketplace.example.com/payment_settings_url" }
    community = Struct.new(:full_domain, :name, :full_name, :custom_email_from_address, :payment_gateway).new('http://marketplace.example.com', 'Example Marketplace', 'Example Marketplace', 'marketplace@example.com', payment_gateway)
    community.define_singleton_method(:payments_in_use?) { true }

    PersonMailer.payment_settings_reminder(listing, recipient, community)
  end

  def receipt_to_payer
    payment = CheckoutPayment.last
    throw "No CheckoutPayments in DB, can't show this mail template." if payment.nil?
    community = payment.community
    PersonMailer.receipt_to_payer(payment, community)
  end

  def braintree_receipt_to_payer
    PersonMailer.braintree_receipt_to_payer(payment, community)
  end

  def braintree_new_payment
    PersonMailer.braintree_new_payment(conversation.payment, community)
  end

  def escrow_canceled
    PersonMailer.escrow_canceled(conversation, community)
  end

  def confirm_reminder
    # Show different template if hold_in_escrow is true
    conversation.community.payment_gateway = nil
    PersonMailer.confirm_reminder(conversation, conversation.requester, conversation.community, 4)
  end

  def confirm_reminder_escrow
    # Show different template if hold_in_escrow is true
    PersonMailer.confirm_reminder(conversation, conversation.requester, conversation.community, 5)
  end

  def admin_escrow_canceled
    PersonMailer.admin_escrow_canceled(conversation, community)
  end

  def transaction_confirmed
    PersonMailer.transaction_confirmed(conversation, community)
  end

  def transaction_automatically_confirmed
    PersonMailer.transaction_automatically_confirmed(conversation, community)
  end

  def conversation_status_changed
    change_conversation_status_to!("accepted")
    PersonMailer.conversation_status_changed(conversation, community)
  end

  def community_updates
    CommunityMailer.community_updates(member, community, [listing])
  end

  def transaction_preauthorized
    change_conversation_status_to!("preauthorized")
    TransactionMailer.transaction_preauthorized(conversation)
  end

  def transaction_preauthorized_reminder
    change_conversation_status_to!("preauthorized")
    TransactionMailer.transaction_preauthorized_reminder(conversation)
  end

  def new_listing_by_followed_person
    PersonMailer.new_listing_by_followed_person(listing, member, community)
  end

  private

  # Private methods to make modifications to default test data

  def change_conversation_status_to!(status)
    conversation.transaction_transitions << FactoryGirl.build(:transaction_transition, to_state: status)
  end
end
