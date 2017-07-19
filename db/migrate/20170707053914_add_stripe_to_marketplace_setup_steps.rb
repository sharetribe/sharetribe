class AddStripeToMarketplaceSetupSteps < ActiveRecord::Migration[5.1]
  def change
    add_column :marketplace_setup_steps, :stripe, :boolean, default: false
  end
end
