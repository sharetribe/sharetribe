class CreateCommunityTranslations < ActiveRecord::Migration
  def change
    create_table :community_translations do |t|
      t.integer :community_id,    null: false
      t.string  :locale,          null: false, limit: 16
      t.string  :translation_key, null: false
      t.text    :translation

      t.timestamps
    end
  end
end
