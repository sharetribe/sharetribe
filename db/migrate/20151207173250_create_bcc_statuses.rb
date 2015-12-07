class CreateBccStatuses < ActiveRecord::Migration
  def change
    create_table :bcc_statuses do |t|
      t.integer :background_check_container_id
      t.text :status
      t.string :bg_color

      t.timestamps
    end

    add_index :bcc_statuses, :background_check_container_id
  end
end
