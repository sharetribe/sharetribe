class ItemSweeper < ActionController::Caching::Sweeper 
  # This sweeper is going to keep an eye on the Item model  
  observe Item 
  
  # If our sweeper detects that a Item was created call this  
  def after_create(item)  
    expire_cache_for(item)  
  end  
  # If our sweeper detects that a Item was updated call this 
  def after_update(item)  
    expire_cache_for(item)  
  end  
  
  # If our sweeper detects that a Item was deleted call this  
  def after_destroy(item)  
    expire_cache_for(item)
  end 
   
  private 
  def expire_cache_for(record)
    #currently expires only the cached list of items 
    update_items_last_changed
  end 
end 