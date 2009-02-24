class AddDescriptionToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :description, :text, :default => ""
  end

  def self.down
    remove_column :items, :description
  end
end
