class UpdatePaypalAccountsBasedOnClonedFrom < ActiveRecord::Migration
  def up
    execute("
        UPDATE paypal_accounts AS pa, people AS p
        SET pa.person_id = p.id
        WHERE
          pa.person_id = p.cloned_from AND
          pa.community_id = p.community_id
      ")
  end

  def down
    execute("
      UPDATE paypal_accounts AS pa, people AS p
      SET pa.person_id = p.cloned_from
      WHERE
        pa.person_id = p.id AND
        p.cloned_from IS NOT NULL
    ")
  end
end
