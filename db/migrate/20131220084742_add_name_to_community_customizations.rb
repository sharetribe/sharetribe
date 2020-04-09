class AddNameToCommunityCustomizations < ActiveRecord::Migration[5.2]
def change
    add_column :community_customizations, :name, :string, :after => :locale
  end
end
