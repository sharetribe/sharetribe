class CreateCommunitySocialLogos < ActiveRecord::Migration[5.1]
  def change
    create_table :community_social_logos do |t|
      t.references :community
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.boolean :image_processing

      t.timestamps
    end
  end
end
