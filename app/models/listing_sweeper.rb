class ListingSweeper < ActionController::Caching::Sweeper 
  # This sweeper is going to keep an eye on the Listing model  
  observe Listing 
  
  # If our sweeper detects that a Listing was created call this  
  def after_create(listing)  
    expire_cache_for(listing)  
  end  
  # If our sweeper detects that a Listing was updated call this 
  def after_update(listing)  
    expire_cache_for(listing)  
  end  
  
  # If our sweeper detects that a Listing was deleted call this  
  def after_destroy(listing)  
    expire_cache_for(listing)
  end 
   
  private 
  def expire_cache_for(record)
    #currently expires only the cached list of listings 
    update_listings_last_changed
  end 
end 