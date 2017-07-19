class AddPaymentFieldToMarketplaceSetupSteps < ActiveRecord::Migration[5.1]
  def up
    add_column :marketplace_setup_steps, :payment, :boolean, default: false
    MarketplaceSetupSteps.update_all('payment = paypal')
  end

  def down
    remove_column :marketplace_setup_steps, :payment
  end
end
