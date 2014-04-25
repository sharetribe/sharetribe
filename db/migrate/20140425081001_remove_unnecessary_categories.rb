class RemoveUnnecessaryCategories < ActiveRecord::Migration
  def up
    community_id_null = Category.where("community_id IS NULL")
    puts "Found #{community_id_null.count} categories without community id, deleting them..."
    community_id_null.delete_all
  end
end
