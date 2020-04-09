class PaypalAccountEmailCanBeNull < ActiveRecord::Migration[5.2]
def up
    change_column_null :paypal_accounts, :email, true
  end

  def down
    change_column_null :paypal_accounts, :email, false
  end
end
