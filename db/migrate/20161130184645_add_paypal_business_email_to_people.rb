class AddPaypalBusinessEmailToPeople < ActiveRecord::Migration
  def change
    add_column :people, :paypal_business_email, :string
  end
end
