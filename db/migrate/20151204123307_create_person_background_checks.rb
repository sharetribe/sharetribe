class CreatePersonBackgroundChecks < ActiveRecord::Migration
  def change
    create_table :person_background_checks do |t|
      t.string :person_id
      t.integer :background_check_container_id
      t.text :value
      t.attachment :document

      t.timestamps
    end

    add_index :person_background_checks, :person_id
    add_index :person_background_checks, :background_check_container_id
  end
end
