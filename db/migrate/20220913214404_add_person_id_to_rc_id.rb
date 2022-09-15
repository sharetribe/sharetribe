class AddPersonIdToRcId < ActiveRecord::Migration[5.2]
  def change
    add_column :user_rocketchat_id, :person_id, :string
    
  end
end
