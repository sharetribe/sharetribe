class AddApiCountryToPaymentSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :payment_settings, :api_country, :string
  end
end
