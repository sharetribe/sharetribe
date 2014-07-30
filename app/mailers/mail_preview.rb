#require 'factory_girl'

class MailPreview < MailView
  include MailViewTestData

  def new_payment
    PersonMailer.new_payment(checkout_payment, checkout_community)
  end

  def payment_settings_reminder
    PersonMailer.payment_settings_reminder(listing, member, community)
  end

  def receipt_to_payer
    PersonMailer.receipt_to_payer(checkout_payment, checkout_community)
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
