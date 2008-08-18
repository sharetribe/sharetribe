class CreatePersonComments < ActiveRecord::Migration
  def self.up
    create_table :person_comments do |t|
      t.string :author_id
      t.string :target_person_id
      t.text :text_content
      t.integer :grade
      t.string :task_type
      t.integer :task_id

      t.timestamps
    end
  end

  def self.down
    drop_table :person_comments
  end
end
