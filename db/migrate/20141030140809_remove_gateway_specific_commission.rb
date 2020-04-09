class RemoveGatewaySpecificCommission < ActiveRecord::Migration[5.2]
def up
    remove_column :payment_gateways, :gateway_commission_percentage
    remove_column :payment_gateways, :gateway_commission_fixed_cents
    remove_column :payment_gateways, :gateway_commission_fixed_currency
  end

  def down
    add_column :payment_gateways, :gateway_commission_percentage, :integer, after: :updated_at
    add_column :payment_gateways, :gateway_commission_fixed_cents, :integer, after: :gateway_commission_percentage
    add_column :payment_gateways, :gateway_commission_fixed_currency, :string, after: :gateway_commission_fixed_cents
  end
end
