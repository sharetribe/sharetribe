class AddMenuLink < ActiveRecord::Migration
  def up
    create_table :menu_links do |t|
      t.integer :community_id
      t.timestamps
    end
  end

  def down
    drop_table :menu_links
  end
end
