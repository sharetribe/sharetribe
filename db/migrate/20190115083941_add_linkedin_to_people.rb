class AddLinkedinToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :linkedin_id, :string
    add_index :people, :linkedin_id
    add_index :people, [:community_id, :linkedin_id]
  end
end
