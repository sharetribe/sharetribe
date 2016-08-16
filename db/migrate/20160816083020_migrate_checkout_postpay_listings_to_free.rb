class MigrateCheckoutPostpayListingsToFree < ActiveRecord::Migration
  def up
    # 1) Find all listings where transaction process is "postpay" and payment gateway is "Checkout"
    # 2) Change the listings' transaction process to "none"

    execute("
      UPDATE listings l
      LEFT JOIN transaction_processes txp_current ON (txp_current.id = l.transaction_process_id)
      LEFT JOIN payment_gateways pg ON (pg.community_id = l.community_id)
      SET l.transaction_process_id = (SELECT id FROM transaction_processes WHERE community_id = l.community_id AND process = 'none' AND author_is_seller = 1)
      WHERE txp_current.process = 'postpay' AND pg.type = 'Checkout';
    ")
  end

  def down
    # Nothing here
  end
end
