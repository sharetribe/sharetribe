class PageLoadedJob < Struct.new(:person_id, :host) 
  
  def perform
    current_user = Person.find(person_id)
    current_user.active_days_count += 1
    current_user.last_page_load_date = DateTime.now
    current_user.save
    Badge.assign_with_levels("enthusiast", current_user.active_days_count, current_user, [5, 30, 100], host)
  end
  
end