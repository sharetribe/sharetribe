class RemovePaymentsInUseFromCommunities < ActiveRecord::Migration[5.2]
def up
    remove_column :communities, :payments_in_use
  end

  def down
    add_column :communities, :payments_in_use, :boolean, :default => false
  end
end
