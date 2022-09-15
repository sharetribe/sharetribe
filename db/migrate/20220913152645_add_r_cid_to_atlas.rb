class AddRCidToAtlas < ActiveRecord::Migration[5.2]
  def change
    create_table :user_rocketchat_id do |t|
      t.string :RC_id
    end
  end
end
