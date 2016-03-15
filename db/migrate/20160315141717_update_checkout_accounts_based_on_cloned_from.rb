class UpdateCheckoutAccountsBasedOnClonedFrom < ActiveRecord::Migration
  def up
    ActiveRecord::Base.transaction do
      people = select_all("
        SELECT * FROM people
        WHERE cloned_from IN
        (SELECT person_id
         FROM checkout_accounts)      
        ")

      people.each { |p|
        execute("
          INSERT INTO checkout_accounts (
            company_id_or_personal_id, merchant_id,
            merchant_key, person_id, created_at, updated_at)
	        (SELECT
            company_id_or_personal_id, merchant_id,
            merchant_key, #{quote(p['id'])}, created_at, updated_at
          FROM checkout_accounts
          WHERE person_id = #{quote(p['cloned_from'])})
          ")
      }
    end
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
