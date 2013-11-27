class AddTermsChangeAllowedAndPrivacyPolicyChangeAllowedToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :terms_change_allowed, :boolean, :default => false
    add_column :communities, :privacy_policy_change_allowed, :boolean, :default => false
  end
end
