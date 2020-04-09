class AddAttachmentImageToPeople < ActiveRecord::Migration[5.2]
  def self.up
    add_column :people, :image_file_name, :string
    add_column :people, :image_content_type, :string
    add_column :people, :image_file_size, :integer
    add_column :people, :image_updated_at, :datetime
  end

  def self.down
    remove_column :people, :image_file_name
    remove_column :people, :image_content_type
    remove_column :people, :image_file_size
    remove_column :people, :image_updated_at
  end
 
end
