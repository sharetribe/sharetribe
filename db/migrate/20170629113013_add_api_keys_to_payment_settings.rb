class AddApiKeysToPaymentSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :payment_settings, :api_client_id, :string
    add_column :payment_settings, :api_private_key, :string
    add_column :payment_settings, :api_publishable_key, :string
    add_column :payment_settings, :api_verified, :boolean
    add_column :payment_settings, :api_visible_private_key, :string
  end
end
