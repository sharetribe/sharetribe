class CreateBraintreeAccounts < ActiveRecord::Migration
  def change
    create_table :braintree_accounts do |t|

      t.timestamps
    end
  end
end
