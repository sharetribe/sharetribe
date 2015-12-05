class CreateBackgroundCheckContainers < ActiveRecord::Migration
  def change
    create_table :background_check_containers do |t|
      t.string :name
      t.integer :community_id
      t.string :container_type
      t.attachment :icon
      t.string :button_text
      t.text :placeholder_text
      t.boolean :active
      t.boolean :visible
      t.text :status
      t.string :status_bg_color

      t.timestamps
    end

    add_index :background_check_containers, :community_id
  end
end