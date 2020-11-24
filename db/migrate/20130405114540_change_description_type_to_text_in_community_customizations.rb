class ChangeDescriptionTypeToTextInCommunityCustomizations < ActiveRecord::Migration
  def up
    change_column :community_customizations, :description, :text
  end

  def down
    change_column :community_customizations, :description, :string
  end
end
