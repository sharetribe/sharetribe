class CreateSocialLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :social_links do |t|
      t.integer :community_id
      t.integer :provider
      t.string :url
      t.integer :sort_priority, default: 0
      t.boolean :enabled, default: false

      t.timestamps
    end
    add_index :social_links, :community_id
  end
end
