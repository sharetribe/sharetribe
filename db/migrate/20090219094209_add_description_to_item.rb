class AddDescriptionToItem < ActiveRecord::Migration[5.2]
  def self.up
    add_column :items, :description, :text, :default => ""
  end

  def self.down
    remove_column :items, :description
  end
end
