class AddLotOfMissingIndexes < ActiveRecord::Migration
  def up
     add_index :community_customizations, :community_id
     add_index :categories, :parent_id
     add_index :share_types, :parent_id
     add_index :communities_listings, :community_id
     add_index :community_memberships, :community_id
     add_index :emails, :person_id
     add_index :event_feed_events, :community_id
     add_index :invitations, :inviter_id
     add_index :invitations, :code
     add_index :listing_followers, :person_id
     add_index :organization_memberships, :person_id
     add_index :payment_rows, :payment_id
     add_index :payments, :payer_id
     add_index :payments, :conversation_id
     add_index :people, :id

     # remove old style category indexes
     
     remove_index :listings, :name => "index_listings_on_category" if index_name_exists?(:listings, "index_listings_on_category", false)
     remove_index :listings, :name => "index_listings_on_share_type" if index_name_exists?(:listings, "index_listings_on_share_type", false)

     add_index :listings, :category_id
     add_index :listings, :share_type_id


   end

   def down
     remove_index :community_customizations, :community_id
     remove_index :categories, :parent_id
     remove_index :share_types, :parent_id
     remove_index :communities_listings, :community_id
     remove_index :community_memberships, :community_id
     remove_index :emails, :person_id
     remove_index :event_feed_events, :community_id
     remove_index :invitations, :inviter_id
     remove_index :invitations, :code
     remove_index :listing_followers, :person_id
     remove_index :organization_memberships, :person_id
     remove_index :payment_rows, :payment_id
     remove_index :payments, :payer_id
     remove_index :payments, :conversation_id
     remove_index :people, :id

     remove_index :listings, :category_id
     remove_index :listings, :share_type_id

     # if rolling back return the old ones
     add_index :listings, :category_old, :name => "index_listings_on_category"
     add_index :listings, :share_type_old, :name => "index_listings_on_share_type"

   end
end
