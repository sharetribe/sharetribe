class AddUuidToExistingCommunities < ActiveRecord::Migration
  def change
    execute "UPDATE communities SET uuid=UNHEX(REPLACE(UUID(), '-', '')) WHERE uuid IS NULL"
  end
end
