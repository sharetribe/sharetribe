class AddHowToUseToCommunityCustomizations < ActiveRecord::Migration
  def change
    add_column :community_customizations, :how_to_use, :text
  end
end
