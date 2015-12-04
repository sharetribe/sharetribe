class CreateSearchSettings < ActiveRecord::Migration
  def change
    create_table :search_settings do |t|
      t.integer :community_id,    null: false
      t.string  :main_search,     null: false, default: 'KEYWORD'

      t.timestamps null: false
    end
  end
end
