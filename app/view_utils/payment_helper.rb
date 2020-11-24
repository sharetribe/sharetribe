module PaymentHelper

  module_function

  def open_listings_with_payment_process?(community_id, user_id)
    payment_process_ids = TransactionProcess.where(community_id: community_id).where.not(process: 'none').pluck(:id)

    if payment_process_ids.empty?
      false
    else
      listing_count = Listing
                      .where(
                        community_id: community_id,
                        author_id: user_id,
                        open: true,
                        transaction_process_id: payment_process_ids)
                      .count

      listing_count > 0
    end
  end
end
