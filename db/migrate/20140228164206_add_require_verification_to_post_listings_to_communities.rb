class AddRequireVerificationToPostListingsToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :require_verification_to_post_listings, :boolean, :default => false
  end
end
