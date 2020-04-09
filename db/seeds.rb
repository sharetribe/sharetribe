Listing.find(:all).each { |listing| listing.update_attribute :last_modified, listing.created_at}
