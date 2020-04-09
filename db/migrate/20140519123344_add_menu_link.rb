class AddMenuLink < ActiveRecord::Migration[5.2]
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
