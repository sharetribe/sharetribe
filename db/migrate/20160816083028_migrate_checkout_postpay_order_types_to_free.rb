class MigrateCheckoutPostpayOrderTypesToFree < ActiveRecord::Migration
  def up
    # 1) Find all listing shapes (i.e. Order Types) where transaction process is "postpay" and payment gateway is "Checkout"
    # 2) Change the listing shapes' transaction process to "none"

    execute("
      UPDATE listing_shapes ls
      LEFT JOIN transaction_processes txp_current ON (txp_current.id = ls.transaction_process_id)
      LEFT JOIN payment_gateways pg ON (pg.community_id = ls.community_id)
      SET ls.transaction_process_id = (SELECT id FROM transaction_processes WHERE community_id = ls.community_id AND process = 'none' AND author_is_seller = 1)
      WHERE txp_current.process = 'postpay' AND pg.type = 'Checkout';
    ")
  end

  def down
    # Nothing here
  end
end
