class CreateRocketChatIds < ActiveRecord::Migration[5.2]
  def change
    create_table :rocket_chat_ids do |t|
      t.string :RC_id
      t.string :person_id

      t.timestamps
    end
  end
end
