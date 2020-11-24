class CreateMarketplaceSetupSteps < ActiveRecord::Migration
  def change
    create_table :marketplace_setup_steps do |t|
      t.integer :community_id, null: false
      t.boolean :slogan_and_description, null: false, default: false
      t.boolean :cover_photo, null: false, default: false
      t.boolean :filter, null: false, default: false
      t.boolean :paypal, null: false, default: false
      t.boolean :listing, null: false, default: false
      t.boolean :invitation, null: false, default: false
    end

    add_index :marketplace_setup_steps, :community_id, unique: true
  end
end
