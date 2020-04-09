class EditPersonComment < ActiveRecord::Migration[5.2]
def self.up
    remove_column :person_comments, :task_type
    remove_column :person_comments, :task_id
    change_column :person_comments, :grade, :float
  end

  def self.down
    add_column :person_comments, :task_type, :string
    add_column :person_comments, :task_id, :integer
    change_column :person_comments, :grade, :integer
  end
end
