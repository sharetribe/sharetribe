class KassiEventsSweeper < ActionController::Caching::Sweeper 
  # This sweeper is going to keep an eye on the KassiEvent model  
  observe KassiEvent 
  
  # If our sweeper detects that a KassiEvent was created call this  
  def after_create(event)  
    expire_cache_for(event)  
  end  
  # If our sweeper detects that a KassiEvent was updated call this 
  def after_update(event)  
    expire_cache_for(event)  
  end  
  
  # If our sweeper detects that a KassiEvent was deleted call this  
  def after_destroy(event)  
    expire_cache_for(event)
  end 
   
  private 
  def expire_cache_for(event)
    #currently expires only the cached list of kassi_events 
    CacheHelper.update_kassi_events_last_changed
  end 
end