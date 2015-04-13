class CreateFeatureFlags < ActiveRecord::Migration
  def change
    create_table :feature_flags do |t|
      t.integer :community_id, null: false
      t.boolean :shape_ui, default: false, null: false

      t.timestamps null: false

    end

    add_index :feature_flags, :community_id
  end
end
