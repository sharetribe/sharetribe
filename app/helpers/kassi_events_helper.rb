module KassiEventsHelper
  
  # Returns a title for the kassi event 
  def get_title(kassi_event)
    if kassi_event.eventable_type.eql?("Item")
      t(:lent_item) + ": " + h(kassi_event.eventable.title.downcase)
    elsif kassi_event.eventable_type.eql?("Favor")
      t(:done_favor) + ": " + h(kassi_event.eventable.title.downcase)
    elsif kassi_event.eventable_type.eql?("Reservation")
      t(:lent_items) + ": " + kassi_event.eventable.items.collect { |item| h(item.title.downcase) }.join(", ")
    else
      t("#{kassi_event.eventable.category}_title") + ': "' + kassi_event.eventable.title + '"'
    end      
  end
  
end
