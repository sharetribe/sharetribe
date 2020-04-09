class AddNotNullIndexToStarterUuidAndListingAuthorUuid < ActiveRecord::Migration[5.2]
  def change
    change_column_null :transactions, :starter_uuid, false
    change_column_null :transactions, :listing_author_uuid, false
  end
end
