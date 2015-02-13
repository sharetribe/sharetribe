class AddExpressCheckoutUrlToPaypalToken < ActiveRecord::Migration
  def change
    add_column :paypal_tokens, :express_checkout_url, :string
  end
end
