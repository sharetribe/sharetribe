class CreateAuthTokens < ActiveRecord::Migration
  def up
     create_table :auth_tokens do |t|
        t.string :token
        t.string :person_id
        t.datetime :expires_at
        t.integer :times_used
        t.datetime :last_use_attempt

        t.timestamps
      end
  end

  def down
    drop_table :auth_tokens
  end
end
