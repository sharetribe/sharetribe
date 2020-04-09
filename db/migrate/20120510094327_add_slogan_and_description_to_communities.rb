class AddSloganAndDescriptionToCommunities < ActiveRecord::Migration[5.2]
def self.up
    add_column :communities, :slogan, :string
    add_column :communities, :description, :text
  end

  def self.down
    remove_column :communities, :description
    remove_column :communities, :slogan
  end
end
