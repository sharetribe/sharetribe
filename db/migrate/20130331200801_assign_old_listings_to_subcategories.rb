# encoding: UTF-8
class AssignOldListingsToSubcategories < ActiveRecord::Migration
  
  def up
    keywords = [
      ["books", /kirja|book|kirjoja|libro|livre/i],
      ["tools", /tool|työkalu|työväline|saha|vasara|pora|kives|silppuri|hammer|saw|pora|drill|hioma|leikkuri/i],
      ["furniture", /sohva|sofa|kaappi|hylly|lipasto|sänky|bed|cupboard|table|microwave|desk|chair|matto|tuoli|pöytä/i],
      ["electronics", /tv|tietokone|computer|laptop|phone|kännykkä|ipod|ipad|iphone|androind|modem|tulostin|printer|screen|näyttö|samsung|canon|nikon|apple|microsoft/i],
      ["film", /movie|leffa|dvd|elokuva/i],
      ["clothes", /takki|neule|coat|haalari|pusero|paita|housut|vaatteet|vaate|cloth|jeans|dress|kengät|shoe/i],
      ["outdoors", /rinkka|teltta/i],
      ["garden", /taimi|mukula|multa/i],
      ["sports", /maila|badminton|urheilu|racket|bike|pyörä|snowboard|ski|hiihto|laskettelu|polkupy/i],
      ["music", /cd|levy|kitara|guitar|musiikki/i],
      ["travel", /laukku|matka|viking|silja/i],
      ["food", /astia|plate|cup|fork|knive|veitsi|haaruk|lusik|ruoka|food|cooking|keitto|kulho|keitin/i],
    ]
    other = Category.find_by_name("other")
    
    Listing.find_each do |listing|
      if listing.category.name == "item" && listing.open && (listing.valid_until.nil? || listing.valid_until > Time.now)
      
        subcategory = other
        keywords.each do |arr|
          if listing.title && listing.title.match(arr[1]) 
            subcategory = Category.find_by_name(arr[0])
            puts "ASSIGNED (by title) SUBCATEGORY '#{arr[0]}' to #{listing.title}"
            break
          end
        end
      
        # if didn't match to any subcat by title, try tags 
        if subcategory == other
          keywords.each do |arr|
            if listing.tags.present? && listing.tags.collect(&:name).join(",").match(arr[1])
              subcategory = Category.find_by_name(arr[0])
              puts "ASSIGNED (by tags) SUBCATEGORY '#{arr[0]}' to #{listing.title}"
              break
            end
          end
        end
      
        # if didn't match to any subcat yet, look in description
        if subcategory == other
          keywords.each do |arr|
            if listing.description && listing.description.match(arr[1])
              subcategory = Category.find_by_name(arr[0])
              puts "ASSIGNED (by desc) SUBCATEGORY '#{arr[0]}' to #{listing.title}"
              break
            end
          end
        end
      
        if subcategory == other
          puts "Could NOT find subcategory for listing #{listing.title} ID: #{listing.id}"
        end
      
        listing.update_column(:category_id, subcategory.id)
      end
    end
  end

  def down
    Listing.find_each do |listing|
      listing.update_column(:category_id, listing.category.top_level_parent.id)
    end
  end
end
