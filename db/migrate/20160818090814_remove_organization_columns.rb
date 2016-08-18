class RemoveOrganizationColumns < ActiveRecord::Migration
  def change
    remove_column :communities, :only_organizations, :boolean, after: :wide_logo_updated_at
    remove_column :people, :organization_name, :string, limit: 255, after: :is_organization
    remove_column :people, :is_organization, :boolean, after: :min_days_between_community_updates
    remove_column :payments, :organization_id, :string, limit: 255, after: :recipient_id
    remove_column :listings, :organization_id, :integer, after: :action_button_tr_key
  end
end
