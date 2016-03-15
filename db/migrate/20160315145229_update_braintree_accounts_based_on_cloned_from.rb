class UpdateBraintreeAccountsBasedOnClonedFrom < ActiveRecord::Migration
  def up
    execute("
      UPDATE
        braintree_accounts AS ba,
        people AS p
        SET ba.person_id = p.id
        WHERE
          ba.person_id = p.cloned_from AND
          ba.community_id = p.community_id
      ")
  end

  def down
    execute("
      UPDATE
        braintree_accounts AS ba,
        people AS p
        SET ba.person_id = p.cloned_from
        WHERE
          ba.person_id = p.id AND
          p.cloned_from IS NOT NULL
      ")
  end
end
