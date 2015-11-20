class CreateFacebookSignupFails < ActiveRecord::Migration
  def change
    create_table :facebook_signup_fails do |t|
      t.integer :community_id
      t.text :auth_data

      t.timestamps
    end
  end
end
