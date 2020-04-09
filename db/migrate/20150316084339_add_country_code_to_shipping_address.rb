class AddCountryCodeToShippingAddress < ActiveRecord::Migration[5.2]
def change
    add_column :shipping_addresses, :country_code, :string, limit: 8
  end
end
