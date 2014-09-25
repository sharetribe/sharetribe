class MoveCheckoutDataToCheckoutAccount < ActiveRecord::Migration
  def up
    execute("INSERT INTO checkout_accounts (company_id, merchant_id, merchant_key, person_id, created_at, updated_at)
             (SELECT company_id, checkout_merchant_id, checkout_merchant_key, id, now(), now()
             FROM people
             WHERE people.checkout_merchant_key IS NOT NULL)")
  end

  def down
    execute("UPDATE people
             INNER JOIN checkout_accounts ON (people.id = checkout_accounts.person_id)
             SET people.company_id = checkout_accounts.company_id,
                 people.checkout_merchant_id = checkout_accounts.merchant_id,
                 people.checkout_merchant_key = checkout_accounts.merchant_key")
    execute("DELETE FROM checkout_accounts")
  end
end
