class SendPaymentReceipts < Struct.new(:transaction_id)

  include DelayedAirbrakeNotification

  def perform
    transaction = Transaction.find(transaction_id)
    set_service_name!(transaction.community_id)
    receipt_to_seller = seller_should_receive_receipt(transaction.listing_author_id)

    receipts =
      case transaction.payment_gateway

      when :paypal, :stripe
        community = Community.find(transaction.community_id)

        receipts = []
        receipts << TransactionMailer.payment_receipt_to_seller(transaction) if receipt_to_seller
        receipts << TransactionMailer.payment_receipt_to_buyer(transaction)
        receipts

      else
        []
      end

    receipts.each { |receipt_mail| MailCarrier.deliver_now(receipt_mail) }
  end

  private

  def seller_should_receive_receipt(seller_id)
    Person.find(seller_id).should_receive?("email_about_new_payments")
  end

  def set_service_name!(community_id)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

end
