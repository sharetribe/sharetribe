class CopyFavorsAndItemsAsListings < ActiveRecord::Migration
  class Item < ActiveRecord::Base
  end
  class Favor < ActiveRecord::Base
  end
  def self.up
    say "Copying all #{Item.count} items as listings"
    say "The old data from items table IS NOT DELETED by this migration", true
    
    Item.all.each do |item|
      listing = Listing.new({:author_id => item.owner_id,
                             :category => "item" ,
                             :listing_type => "offer",
                             :title => item.title,
                             :description => item.description,
                             :visibility => (item.status == "disabled" ? "disabled" : item.visibility),
                             :share_type_attributes => ["lend"],
                             :open => (item.status == "enabled"),
                             :status => (item.status == "disabled" ? "disabled" : "open"),
                             :created_at => item.created_at
                             })
      
      if item.updated_at != item.created_at
        listing.last_modified = item.updated_at
      end
      
      listing.save!
      listing.update_attribute("updated_at", item.updated_at)
      print "."; STDOUT.flush
    end
    
    puts ""
    say "Copying all #{Favor.count} favors as listings"
    say "The old data from favors table IS NOT DELETED by this migration", true
    
    Favor.all.each do |favor|
      listing = Listing.new({:author_id => favor.owner_id,
                                  :category => "favor" ,
                                  :listing_type => "offer",
                                  :title => favor.title,
                                  :description => favor.description,
                                  :visibility => (favor.status == "disabled" ? "disabled" : favor.visibility),
                                  :open => (favor.status == "enabled"),
                                  :status => (favor.status == "disabled" ? "disabled" : "open"),
                                  :updated_at => favor.updated_at,
                                  :created_at => favor.created_at})
                                  
      if favor.updated_at != favor.created_at
        listing.last_modified = favor.updated_at
      end
      
      listing.save!
      listing.update_attribute("updated_at", favor.updated_at)
      print "."; STDOUT.flush
    end
    puts ""
  end

  def self.down
    raise  ActiveRecord::IrreversibleMigration, "The changes made by this migration are not easy to undo.\
         However, this migration didn't delete any data, so you can quite safely remove this raise IrreversibleMigration."
  end
end
