class AddIndexToMenuLinksId < ActiveRecord::Migration
  def change
    add_index :menu_link_translations, :menu_link_id
  end
end
