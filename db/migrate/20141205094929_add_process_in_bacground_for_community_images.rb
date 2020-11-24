class AddProcessInBacgroundForCommunityImages < ActiveRecord::Migration
  def up
    change_table :communities do |t| 
      t.boolean :logo_processing
      t.boolean :wide_logo_processing
      t.boolean :cover_photo_processing
      t.boolean :small_cover_photo_processing
      t.boolean :favicon_processing
    end
  end

  def down
    change_table :communities do |t| 
      t.remove :logo_processing, :wide_logo_processing, :cover_photo_processing, :small_cover_photo_processing, :favicon_processing
    end
  end
end
