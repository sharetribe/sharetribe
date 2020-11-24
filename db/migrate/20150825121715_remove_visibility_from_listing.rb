class RemoveVisibilityFromListing < ActiveRecord::Migration
  def up
    remove_column :listings, :visibility
  end

  def down
    add_column :listings, :visibility, :string, after: :sort_date, default: "this_community"
  end
end
