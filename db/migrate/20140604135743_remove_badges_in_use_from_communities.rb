class RemoveBadgesInUseFromCommunities < ActiveRecord::Migration[5.2]
def up
    remove_column :communities, :badges_in_use
  end

  def down
    add_column :communities, :badges_in_use, :boolean, default: false, after: :minimum_price_cents
  end
end