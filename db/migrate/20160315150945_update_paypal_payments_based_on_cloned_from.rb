class UpdatePaypalPaymentsBasedOnClonedFrom < ActiveRecord::Migration
  def up
    execute("
      UPDATE paypal_payments AS pp, people as p
      SET pp.merchant_id = p.id
      WHERE
        pp.merchant_id = p.cloned_from AND
        pp.community_id = p.community_id
      ")
  end

  def down
    execute("
      UPDATE paypal_payments AS pp, people AS p
      SET pp.merchant_id = p.cloned_from
      WHERE
        pp.merchant_id = p.id AND
        p.cloned_from IS NOT NULL
      ")
  end
end
