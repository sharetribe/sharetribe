class AddStorefrontLabelToCommunityCustomizations < ActiveRecord::Migration[5.2]
  def change
    add_column :community_customizations, :storefront_label, :string
  end
end
