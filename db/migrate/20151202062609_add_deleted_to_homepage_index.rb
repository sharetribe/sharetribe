class AddDeletedToHomepageIndex < ActiveRecord::Migration
  def up
    remove_index "listings", :name => "homepage_query"
    remove_index "listings", :name => "homepage_query_valid_until"
    add_index "listings", ["community_id", "open", "sort_date", "deleted"], :name => "homepage_query"
    add_index "listings", ["community_id", "open", "valid_until", "sort_date", "deleted"], :name => "homepage_query_valid_until"
  end

  def down
    remove_index "listings", :name => "homepage_query"
    remove_index "listings", :name => "homepage_query_valid_until"
    add_index "listings", ["community_id", "open", "sort_date"], :name => "homepage_query"
    add_index "listings", ["community_id", "open", "valid_until", "sort_date"], :name => "homepage_query_valid_until"
  end
end
