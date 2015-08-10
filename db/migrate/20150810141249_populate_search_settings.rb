class PopulateSearchSettings < ActiveRecord::Migration
  def up
    execute("
      INSERT INTO search_settings (community_id, main_search, created_at, updated_at)
      SELECT c.id, 'KEYWORD', NOW(), NOW()
      FROM communities c;
    ")
  end

  def down
    execute("
      DELETE FROM search_settings;
    ")
  end
end
