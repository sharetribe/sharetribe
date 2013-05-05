class AddBlankSlateToCommunityCustomizations < ActiveRecord::Migration
  def change
    add_column :community_customizations, :blank_slate, :text
  end
end
