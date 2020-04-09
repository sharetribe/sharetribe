class AddUuidToExistingListings < ActiveRecord::Migration[5.2]
def change
    execute "UPDATE listings SET uuid=UNHEX(REPLACE(UUID(), '-', '')) WHERE uuid IS NULL"
  end
end
