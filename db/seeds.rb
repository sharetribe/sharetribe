# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
#  listing_type = valid_st.keys[SecureRandom.random_number(valid_st.keys.length)]

default_categories = [
  {
  "item" => [
    "tools",
    "sports",
    "music",
    "books",
    "games",
    "furniture",
    "outdoors",
    "food",
    "electronics",
    "pets",
    "film",
    "clothes",
    "garden",
    "travel",
    "other"
    ]
  },
  "favor",
  "rideshare",
  "housing" 
]

default_share_types = {
  "offer" => {:categories => ["item", "favor", "rideshare", "housing"]},
    "sell" => {:parent => "offer", :categories => ["item", "housing"]},
    "rent_out" => {:parent => "offer", :categories => ["item", "housing"]},
    "lend" => {:parent => "offer", :categories => ["item"]}, 
    #"trade" => {:parent => "offer", :categories => ["item"]}, 
    "give_away" => {:parent => "offer", :categories => ["item"]},
    "share_for_free" => {:parent => "offer", :categories => ["housing"]},
    
  "request" => {:categories => ["item", "favor", "rideshare", "housing"]}, 
    "buy" => {:parent => "request", :categories => ["item", "housing"]},
    "rent" => {:parent => "request", :categories => ["item", "housing"]},
    "borrow" => {:parent => "request", :categories => ["item"]},
    #"trade" => {:parent => "request", :categories => ["item"]}, 
    "receive" => {:parent => "request", :categories => ["item"]}, 
    "accept_for_free" => {:parent => "request", :categories => ["housing"]}
}


default_categories.each do |category| 
  if category.class == String
    Category.create([{:name => category, :icon => category}])
  elsif category.class == Hash
    parent = Category.create(:name => category.keys.first)
    category.values.first.each do |subcategory|
      c = Category.create({:name => subcategory, :icon => subcategory, :parent_id => parent.id})
      # As subcategories won't get their own link to share_types (as they inherit that from parent category)
      # We create a CommunityCategory entry here to mark that these subcategories exist in the default tribe
      CommunityCategory.create(:category => c)
    end
  else
    puts "Invalid data for default_categories. It must be array of Strings and Hashes."
    return
  end
end

default_share_types.each do |share_type, details|
  parent = ShareType.find_by_name(details[:parent]) if details[:parent]
  s = ShareType.create(:name => share_type, :icon => share_type, :parent => parent)
  details[:categories].each do |category_name|
    c = Category.find_by_name(category_name)
    CommunityCategory.create(:category => c, :share_type => s) if c
  end
end