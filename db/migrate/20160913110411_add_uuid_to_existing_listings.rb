class AddUuidToExistingListings < ActiveRecord::Migration
  def change
    execute "UPDATE listings SET uuid=UNHEX(REPLACE(UUID(), '-', '')) WHERE uuid IS NULL"
  end
end
