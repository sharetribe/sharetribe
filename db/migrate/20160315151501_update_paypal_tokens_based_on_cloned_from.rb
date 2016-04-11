class UpdatePaypalTokensBasedOnClonedFrom < ActiveRecord::Migration
  def up
    execute("
      UPDATE paypal_tokens AS pt, people AS p
      SET pt.merchant_id = p.id
      WHERE
        pt.merchant_id = p.cloned_from AND
        pt.community_id = p.community_id
    ")
  end

  def down
    execute("
      UPDATE paypal_tokens AS pt, people AS p
      SET pt.merchant_id = p.cloned_from
      WHERE
        pt.merchant_id = p.id AND
        p.cloned_from IS NOT NULL
    ")
  end
end
