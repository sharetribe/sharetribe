class RemoveAvailableCurrenciesColumnFromCommunities < ActiveRecord::Migration[5.2]
def change
    remove_column :communities, :available_currencies, :text, after: :service_logo_style
  end
end
