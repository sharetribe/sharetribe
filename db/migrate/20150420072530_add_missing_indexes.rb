class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index "categories", ["community_id"], name: "index_categories_on_community_id"
    add_index "community_plans", ["community_id"], name: "index_community_plans_on_community_id"
    add_index "listings", ["category_id"], name: "index_listings_on_new_category_id"
    add_index "transaction_processes", ["community_id"], name: "index_transaction_process_on_community_id"
    add_index "delayed_jobs", ["locked_at", "created_at"], name: "index_delayed_jobs_on_locked_created"
    add_index "menu_links", ["community_id", "sort_priority"], name: "index_menu_links_on_community_and_sort"
    add_index "people", ["authentication_token"], name: "index_people_on_authentication_token"
  end
end
