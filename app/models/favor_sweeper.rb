class FavorSweeper < ActionController::Caching::Sweeper 
  # This sweeper is going to keep an eye on the Favor model  
  observe Favor 
  
  # If our sweeper detects that a Favor was created call this  
  def after_create(favor)  
    expire_cache_for(favor)  
  end  
  # If our sweeper detects that a favor was updated call this 
  def after_update(favor)  
    expire_cache_for(favor)  
  end  
  
  # If our sweeper detects that a favor was deleted call this  
  def after_destroy(favor)  
    expire_cache_for(favor)
  end 
   
  private 
  def expire_cache_for(record)
    #currently expires only the cached list of favors 
    update_favors_last_changed
  end 
end 