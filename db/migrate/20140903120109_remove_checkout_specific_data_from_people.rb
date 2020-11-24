class RemoveCheckoutSpecificDataFromPeople < ActiveRecord::Migration
  def up
    remove_column :people, :checkout_merchant_id, :checkout_merchant_key, :company_id
  end

  def down
    add_column :people, :company_id, :string, after: :is_organization
    add_column :people, :checkout_merchant_id, :string, after: :company_id
    add_column :people, :checkout_merchant_key, :string, after: :checkout_merchant_id
  end
end
