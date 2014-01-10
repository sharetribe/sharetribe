class AddCommunityIdToCustomFields < ActiveRecord::Migration
  def change
    add_column :custom_fields, :community_id, :integer
  end
end
