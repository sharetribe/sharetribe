#require 'factory_girl'

class MailPreview < MailView
  include MailViewTestData

  def new_payment
    PersonMailer.new_payment(checkout_payment, checkout_community)
  end

  def payment_settings_reminder
    PersonMailer.payment_settings_reminder(listing, member, community)
  end

  def payment_reminder
    PersonMailer.payment_reminder(conversation, member, community)
  end

  def receipt_to_payer
    PersonMailer.receipt_to_payer(checkout_payment, checkout_community)
  end

  def braintree_receipt_to_payer
    TransactionMailer.braintree_receipt_to_payer(payment, community)
  end

  def braintree_new_payment
    TransactionMailer.braintree_new_payment(transaction.payment, community)
  end

  def paypal_receipt_to_payer
    transaction = TransactionService::DataTypes::Transaction.create_transaction({
        id: 999,
        payment_process: :preauthorize,
        payment_gateway: :paypal,
        community_id: 999,
        starter_id: paypal_transaction.starter.id,
        listing_id: paypal_transaction.listing.id,
        listing_title: paypal_transaction.listing.title,
        listing_price: paypal_transaction.listing.price,
        listing_author_id: paypal_transaction.listing.author.id,
        listing_quantity: 1,
        last_transition_at: Time.now,
        current_state: :paid,
        payment_total: Money.new(2000, "USD")
      })

    seller_model = paypal_transaction.listing.author
    buyer_model = paypal_transaction.starter
    community = paypal_transaction.community
    service_fee = Money.new(500, "USD")

    TransactionMailer.paypal_receipt_to_payer(transaction, service_fee, seller_model, buyer_model, community)
  end

  def paypal_new_payment
    transaction = TransactionService::DataTypes::Transaction.create_transaction({
        id: 999,
        payment_process: :preauthorize,
        payment_gateway: :paypal,
        community_id: 999,
        starter_id: paypal_transaction.starter.id,
        listing_id: paypal_transaction.listing.id,
        listing_title: paypal_transaction.listing.title,
        listing_price: paypal_transaction.listing.price,
        listing_author_id: paypal_transaction.listing.author.id,
        listing_quantity: 1,
        last_transition_at: Time.now,
        current_state: :paid,
        payment_total: Money.new(2000, "USD")
      })

    seller_model = paypal_transaction.listing.author
    buyer_model = paypal_transaction.starter
    community = paypal_transaction.community
    service_fee = Money.new(500, "USD")

    TransactionMailer.paypal_new_payment(transaction, service_fee, seller_model, buyer_model, community)
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

  def booking_transaction_automatically_confirmed
    conversation = Conversation.last
    community = conversation.community
    # conversation.status = "confirmed"
    PersonMailer.booking_transaction_automatically_confirmed(conversation, community)
  end

  def conversation_status_changed
    change_conversation_status_to!("accepted")
    PersonMailer.conversation_status_changed(conversation, community)
  end

  def community_updates
    CommunityMailer.community_updates(member, community, [listing])
  end

  def welcome_email
    PersonMailer.welcome_email(member, community)
  end

  def transaction_created
    TransactionMailer.transaction_created(transaction)
  end

  def transaction_preauthorized
    change_conversation_status_to!("preauthorized")
    TransactionMailer.transaction_preauthorized(transaction)
  end

  def transaction_preauthorized_reminder
    change_conversation_status_to!("preauthorized")
    TransactionMailer.transaction_preauthorized_reminder(transaction)
  end

  def new_listing_by_followed_person
    PersonMailer.new_listing_by_followed_person(listing, member, community)
  end

  private

  # Private methods to make modifications to default test data

  def change_conversation_status_to!(status)
    transaction.transaction_transitions << FactoryGirl.build(:transaction_transition, to_state: status)
  end
end
