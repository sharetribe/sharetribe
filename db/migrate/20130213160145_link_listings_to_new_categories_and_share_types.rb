class LinkListingsToNewCategoriesAndShareTypes < ActiveRecord::Migration
  def up
    add_column :listings, :category_id, :integer
    add_column :listings, :share_type_id, :integer
    Listing.find_each do |listing|
      category = Category.find_by_name(listing.read_attribute(:category))
      if category.nil?
        puts "No Category found for #{listing.read_attribute(:category)}. Fix manually listing with id: #{listing.id}" 
      else
        listing.update_column(:category_id, category.id)
      end
      
      share_type_label = listing.read_attribute(:share_type)
      if share_type_label == "trade"
        if listing.listing_type == "offer"
          share_type_label = "offer_to_swap"
        elsif listing.listing_type == "request"
          share_type_label = "request_to_swap"
        end
      end
      
      share_type = ShareType.find_by_name(share_type_label)
      if share_type.nil?
        if ["item", "housing"].include? listing.category.name
          puts "No Share type found for #{listing.read_attribute(:share_type)}. Fix manually listing with id: #{listing.id}" 
        end
      else
        listing.update_column(:share_type_id, share_type.id)
      end
      
    end
    # remove_column :listings, :category
    # remove_column :listings, :subcategory
    # remove_column :listings, :share_type
  end

  def down
    
    #raise  ActiveRecord::IrreversibleMigration, "Rollback of this migration is not fully coded. Implement that if really needed and then remove this IrreversibleMigration line."
    # add_column :listings, :category, :string
    # add_column :listings, :subcategory, :string
    # add_column :listings, :share_type, :string
    # Here should put the category names back in place. Implement this is really needed
    remove_column :listings, :category_id
    remove_column :listings, :share_type_id
  end
end
