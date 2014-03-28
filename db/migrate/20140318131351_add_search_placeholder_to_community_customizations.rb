class AddSearchPlaceholderToCommunityCustomizations < ActiveRecord::Migration
  def change
    add_column :community_customizations, :search_placeholder, :string
  end
end
