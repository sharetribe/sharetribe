class AddGoogleOauth2ToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :google_oauth2_id, :string
    add_index :people, :google_oauth2_id
    add_index :people, [:community_id, :google_oauth2_id]
  end
end
