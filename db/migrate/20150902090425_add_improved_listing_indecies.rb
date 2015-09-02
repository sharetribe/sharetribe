class AddImprovedListingIndecies < ActiveRecord::Migration
  def up
    add_index "listings", ["community_id", "open", "sort_date"], :name => "homepage_query"
    add_index "listings", ["community_id", "open", "valid_until", "sort_date"], :name => "homepage_query_valid_until"
    add_index "listings", ["community_id", "author_id"], :name => "person_listings"

    add_index "listings", ["community_id", "open", "updates_email_at"], :name => "updates_email_listings"
  end

  def down
    remove_index "listings", name: "homepage_query"
    remove_index "listings", name: "homepage_query_valid_until"
    remove_index "listings", name: "person_listings"
    remove_index "listings", name: "updates_email_listings"
  end
end
