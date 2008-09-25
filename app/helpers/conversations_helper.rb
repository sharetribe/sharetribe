module ConversationsHelper

  def create_links_for_participants
    participants = @conversation.participants
    participant_links = []
    participants.each do |participant|
      participant_links << link_to(participant.id, person_path(participant)) unless participant == @current_user
    end
    participant_links.join(", ")
  end

end
