module KassiEventsHelper
  
  # Returns a title for a kassi event displayed in the home page
  def get_kassi_event_label_hash(kassi_event)
    hash = {}
    if kassi_event.eventable_type.eql?("Item")
      hash[:title] = t(:lent_item) + ": " + h(kassi_event.eventable.title.downcase)
      hash[:requester] = [t(:item_borrower), link_to(kassi_event.requester.name, kassi_event.requester)]
      hash[:provider] = [t(:item_lender), link_to(kassi_event.provider.name, kassi_event.provider)]
    elsif kassi_event.eventable_type.eql?("Favor")
      hash[:title] = t(:done_favor) + ": " + h(kassi_event.eventable.title.downcase)
      hash[:requester] = [t(:favor_receiver), link_to(kassi_event.requester.name, kassi_event.requester)]
      hash[:provider] = [t(:favor_realizer), link_to(kassi_event.provider.name, kassi_event.provider)]
    elsif kassi_event.eventable_type.eql?("Reservation")
      reservation_items = kassi_event.eventable.items.collect { |item| h(item.title.downcase) }
      hash[:title] = (reservation_items.size > 1 ? t(:lent_items) : t(:lent_item)) + ": " + reservation_items.join(", ")
      hash[:requester] = [t(:item_borrower), link_to(kassi_event.requester.name, kassi_event.requester)]
      hash[:provider] = [t(:item_lender), link_to(kassi_event.provider.name, kassi_event.provider)]
    else
      hash[:title] = t("#{kassi_event.eventable.category}_title") + ': ' + kassi_event.eventable.title
      if kassi_event.requester
        hash[:requester] = [t("#{kassi_event.eventable.category}_requester_label"), link_to(kassi_event.requester.name, kassi_event.requester)]
        hash[:provider] = [t("#{kassi_event.eventable.category}_provider_label"), link_to(kassi_event.provider.name, kassi_event.provider)]
      elsif kassi_event.buyer
        hash[:requester] = [t(:buyer_label), link_to(kassi_event.buyer.name, kassi_event.buyer)]
        hash[:provider] = [t(:seller_label), link_to(kassi_event.seller.name, kassi_event.seller)]
      else
        party1 = kassi_event.participants.first
        party2 = kassi_event.get_other_party(party1)
        hash[:requester] = [t(:listing_author), link_to(party1.name, party1)]
        hash[:provider] = [t(:listing_replier), link_to(party2.name, party2)]
      end
    end
    hash
  end
  
end
