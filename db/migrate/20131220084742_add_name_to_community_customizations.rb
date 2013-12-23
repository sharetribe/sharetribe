class AddNameToCommunityCustomizations < ActiveRecord::Migration
  def change
    add_column :community_customizations, :name, :string, :after => :locale
  end
end
