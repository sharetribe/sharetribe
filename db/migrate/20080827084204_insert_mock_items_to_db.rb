class InsertMockItemsToDb < ActiveRecord::Migration
  def self.up
    item_data = []
    item_data[0] = {
      :owner_id => "Julia",  
      :title => "Kakkuvatkain", 
    }
    item_data[1] = {
      :owner_id => "Antti",
      :title => "Ketjunkatkaisin"
    }
    item_data[2] = {
      :owner_id => "Antti",
      :title => "Teltta"
    }
    item_data[3] = {
      :owner_id => "Julia",
      :title => "Teltta"
    }
    
    item_data.each do |info|
      item = Item.create(info)
    end
  end

  def self.down
    truncate table Items
  end
end
