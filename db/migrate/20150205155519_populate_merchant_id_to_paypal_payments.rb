class PopulateMerchantIdToPaypalPayments < ActiveRecord::Migration
  def up
    # To migrate seller's Sharetribe person ID to paypal payments, we have to options:
    #
    # - A: By `transaction_id`: Join the `transactions` and `listings` and get the `author_id`
    #   - Problem: There may not be listing (or transaction), if user has been deleted
    # - B: By `receiver_id` and `community_id`: Join `paypal_accounts`
    #   - Problem: There may be multiple accounts per `community_id`, `receiver_id` combination
    #
    # So, what we do here is that we use both options and get the person_id's that we can.

    execute("
      UPDATE paypal_payments

      # Option A
      LEFT JOIN transactions ON (transactions.id = paypal_payments.transaction_id)
      LEFT JOIN listings ON (transactions.listing_id = listings.id)

      # Option B
      LEFT JOIN (
        SELECT person_id, payer_id, community_id FROM paypal_accounts

        # We are looking for personal account, so `person_id` must be non-null
        WHERE person_id IS NOT NULL

        # Group by `payer_id` and `community_id` combination, but include to result
        # ONLY if there is only one hit. Ignore groups of multiple rows, since then
        # we could not say which one is the right one
        GROUP BY payer_id, community_id
        HAVING COUNT(*) = 1

      ) AS accounts
      # Join by matching `payer_id` and `community_id`
      ON (paypal_payments.receiver_id = accounts.payer_id AND paypal_payments.community_id = accounts.community_id)

      # Update `merchant_id` by selecting the first non-nil of author_id and person_id
      SET paypal_payments.merchant_id = COALESCE(listings.author_id, accounts.person_id)

      WHERE
        # pick author_id
        (listings.author_id IS NOT NULL AND accounts.person_id IS NULL) OR
        # pick listing_id
        (listings.author_id IS NULL AND accounts.person_id IS NOT NULL) OR
        # both present, so make sure they match
        (listings.author_id IS NOT NULL AND accounts.person_id IS NOT NULL AND listings.author_id = accounts.person_id)
    ")

  end

  def down
    # noop
  end
end
