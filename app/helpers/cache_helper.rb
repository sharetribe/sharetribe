# This is included to ApplicationController
# Contains helper methods for cache handling
module CacheHelper
  
  # Constants for expire times
  
  # used for things that are stored completely on Kassi db
  KASSI_DATA_CACHE_EXPIRE_TIME = 4.hours
  
  # used for things that are stored in COS db and can be changed without notice
  COS_DATA_CACHE_EXPIRE_TIME = 2.hours

  
  def favors_last_changed 
    Rails.cache.fetch("favors_last_changed", :expires_in => KASSI_DATA_CACHE_EXPIRE_TIME) {Time.now.to_i}
  end

  def update_favors_last_changed 
    Rails.cache.write("favors_last_changed", Time.now.to_i, :expires_in => KASSI_DATA_CACHE_EXPIRE_TIME)
  end
  
  def items_last_changed 
    Rails.cache.fetch("items_last_changed", :expires_in => KASSI_DATA_CACHE_EXPIRE_TIME) {Time.now.to_i}
  end

  def update_items_last_changed 
    Rails.cache.write("items_last_changed", Time.now.to_i, :expires_in => KASSI_DATA_CACHE_EXPIRE_TIME)
  end
  
  def listings_last_changed 
    Rails.cache.fetch("listings_last_changed", :expires_in => KASSI_DATA_CACHE_EXPIRE_TIME) {Time.now.to_i}
  end

  def update_listings_last_changed 
    Rails.cache.write("listings_last_changed", Time.now.to_i, :expires_in => KASSI_DATA_CACHE_EXPIRE_TIME)
  end
  
  def update_caches_dependent_on_friendship(person1, person2)
    [person1, person2].each do |person|
           I18n.available_locales.each do |locale|
             puts "items_list/#{locale.to_s}/#{items_last_changed}/#{person.id}"
             # Rails.cache.delete("items_list/#{locale.to_s}/#{items_last_changed}/#{person.id}")
             # expire_action :controller => :items, :action => :index, :cache_path => "items_list/#{locale.to_s}/#{items_last_changed}/#{person.id}"
           end
         end
    
     # SHOULD USE SOMETHING LIKE ABOVE
      # this one below clears all the caches, so it slows the system down unnecessarily.
    
      update_favors_last_changed
      update_items_last_changed
      update_listings_last_changed
  end
  
  def update_caches_dependent_on_groups(person)
    # I18n.available_locales.each do |locale|
    #   Rails.cache.delete("items_list/#{locale.to_s}/#{items_last_changed}/#{person.id}")
    #  end
    
    # SHOULD USE SOMETHING LIKE ABOVE
    # this one below clears all the caches, so it slows the system down unnecessarily.
    
     update_favors_last_changed
     update_items_last_changed
     update_listings_last_changed
  end
  
  
  # * people_last_changed (Time.now.to_i) tästä ei voi olla varmaa tietoa, joten oltava myös expire-aika
  # * groups_last_changed (Time.now.to_i) tästä ei voi olla varmaa tietoa, joten oltava myös expire-aika
  
end