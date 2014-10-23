class SendPaymentReceipts < Struct.new(:transaction_id)

  include DelayedAirbrakeNotification

  def perform
    transaction = TransactionService::Transaction.query(transaction_id)
    set_service_name!(transaction[:community_id])
    receipt_to_seller = seller_should_receive_receipt(transaction[:listing_author_id])

    receipts =
      case transaction[:payment_gateway]

      when :braintree
        community = Community.find(transaction[:community_id])
        payment = braintree_payment_for(transaction_id)

        receipts = []
        receipts << TransactionMailer.braintree_new_payment(payment, community) if receipt_to_seller
        receipts << TransactionMailer.braintree_receipt_to_payer(payment, community)
        receipts

      when :checkout
        community = Community.find(transaction[:community_id])
        payment = checkout_payment_for(transaction_id)

        receipts = []
        receipts << PersonMailer.new_payment(payment, community) if receipt_to_seller
        receipts << PersonMailer.receipt_to_payer(payment, community)
        receipts

      when :paypal
        community = Community.find(transaction[:community_id])

        receipts = []
        service_fee = transaction[:commission_total]
        receipts << TransactionMailer.paypal_new_payment(transaction, service_fee) if receipt_to_seller
        receipts << TransactionMailer.paypal_receipt_to_payer(transaction, service_fee)
        receipts
      else
        []
      end

    receipts.each { |receipt_mail| receipt_mail.deliver }
  end

  private

  def seller_should_receive_receipt(seller_id)
    Person.find(seller_id).should_receive?("email_about_new_payments")
  end

  def set_service_name!(community_id)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def braintree_payment_for(transaction_id)
    BraintreePayment.where(transaction_id: transaction_id).first
  end

  def checkout_payment_for(transaction_id)
    CheckoutPayment.where(transaction_id: transaction_id).first
  end

end
