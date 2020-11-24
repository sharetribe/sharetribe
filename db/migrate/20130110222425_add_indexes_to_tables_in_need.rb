class AddIndexesToTablesInNeed < ActiveRecord::Migration
  def change
    add_index :community_memberships, [:person_id, :community_id], :name => "memberships"
    add_index :participations, :person_id
    add_index :participations, :conversation_id
    add_index :badges, :person_id
    add_index :communities, :domain
    add_index :listing_followers, :listing_id
    add_index :listings, :category
    add_index :listings, :share_type
    add_index :locations, :person_id
    add_index :locations, :listing_id
    add_index :locations, :community_id
    add_index :messages, :conversation_id
    add_index :notifications, :receiver_id
    add_index :statistics, :community_id
    add_index :testimonials, :receiver_id
    
  end
end
