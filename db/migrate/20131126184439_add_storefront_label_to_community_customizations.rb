class AddStorefrontLabelToCommunityCustomizations < ActiveRecord::Migration
  def change
    add_column :community_customizations, :storefront_label, :string
  end
end
