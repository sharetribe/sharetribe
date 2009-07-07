module ConversationsHelper

  def create_links_for_participants
    participants = @conversation.participants
    participant_links = []
    participants.each do |participant|
      participant_links << link_to(participant.name(session[:cookie]), person_path(participant)) unless participant == @current_user
    end
    participant_links.join(", ")
  end

  def get_last_message(conversation, count = -1)
    if conversation.messages[count].sender == @current_user
      count -= 1
      get_last_message(conversation, count)
    else
      conversation.messages[count]
    end
  end

  def get_last_sent_message(conversation, count = -1)
    if conversation.messages[count].sender != @current_user
      count -= 1
      get_last_sent_message(conversation, count)
    else
      conversation.messages[count]
    end
  end
  
  # Renders links for inbox navi
  def get_inbox_navi_items(person_id)
    navi_items = ActiveSupport::OrderedHash.new
    navi_items["received"] = person_inbox_index_path(@current_user)
    navi_items["sent"] = sent_person_inbox_path(@current_user)
    links = []
    navi_items.each do |name, link|
      if name.to_s.eql?(session[:links_panel_navi])
        links << link_to(t("#{name}_messages") + " <span class='page_entries_info'>(" + page_entries_info(@person_conversations) + ")</span>", link, :class => "links_panel links_panel_selected") 
      else
        links << link_to(t("#{name}_messages"), link, :class => "links_panel")
      end    
    end
    links.join("")
  end
  
  # Returns a status message for a reservation
  def get_reservation_status(reservation)
    owner = get_item_owner(reservation)
    case reservation.status
    when "pending_owner"
      is_current_user?(owner) ? "awaiting_acceptance_from_you" : "awaiting_acceptance_from_other_party"
    when "pending_reserver"
      is_current_user?(owner) ? "awaiting_acceptance_from_other_party" : "awaiting_acceptance_from_you"
    else
      "reservation_" + reservation.status
    end  
  end
  
  # Returns the owner of reserved items
  def get_item_owner(reservation)
    reservation.items.first.owner
  end
  
  def get_amount_value(item, conversation)
    amount = nil
    if conversation.type.eql?("Reservation")
      conversation.item_reservations.each do |item_reservation|
        if item_reservation.item.id == item.id
          amount = item_reservation.amount
        end  
      end
    end
    if amount
      amount
    else
      params[:conversation] ? params[:conversation][:reserved_items][item.id.to_s] : 1
    end
  end

end
