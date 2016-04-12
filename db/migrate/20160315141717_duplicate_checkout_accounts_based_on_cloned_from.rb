class DuplicateCheckoutAccountsBasedOnClonedFrom < ActiveRecord::Migration
  def up
    execute("
      INSERT INTO checkout_accounts
        (company_id_or_personal_id, merchant_id, merchant_key, person_id, created_at, updated_at)
        (SELECT c.company_id_or_personal_id, c.merchant_id, c.merchant_key, cloned_people.id, c.created_at, c.updated_at
         FROM checkout_accounts AS c
         LEFT JOIN people AS cloned_people ON cloned_people.cloned_from = c.person_id
         WHERE cloned_people.cloned_from IS NOT NULL)
      ")
  end

  def down
    execute("
      DELETE ca
      FROM checkout_accounts AS ca, people AS p
      WHERE
        ca.person_id = p.id AND
        p.cloned_from IS NOT NULL
      ")
  end
end
