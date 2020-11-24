class RemoveUnusedColumnsFromListings < ActiveRecord::Migration
  def self.up
    remove_column :listings, :content
    remove_column :listings, :good_thru
    remove_column :listings, :status
    remove_column :listings, :value_cc
    remove_column :listings, :value_other
  end

  def self.down
    add_column :listings, :content, :text
    add_column :listings, :good_thru, :date
    add_column :listings, :status, :string
    add_column :listings, :value_cc, :integer
    add_column :listings, :value_other, :string    
  end
end
