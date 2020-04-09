class MigrateOrganizationUsers < ActiveRecord::Migration[5.2]
def up

  end

  def down
    Person.where(:is_organization => true).each do |member|
      member.is_organization = nil
      member.organization_name = nil
      member.company_id = nil
      member.checkout_merchant_id = nil
      member.checkout_merchant_key = nil
      member.image = nil

      # Save
      member.save!      
    end
  end
end
