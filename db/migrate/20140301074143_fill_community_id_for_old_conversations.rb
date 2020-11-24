class FillCommunityIdForOldConversations < ActiveRecord::Migration
  def up
    Conversation.find_each do |conversation|
      if conversation.community_id.nil?
        match_found = false
        first_participant = conversation.participants.first
        second_participant = conversation.participants.last
        if first_participant && second_participant
        
          second_participant.communities.each do |community|
            if first_participant.communities.include?(community)
              # match found
              match_found = true
              conversation.update_column(:community_id, community.id)
              puts "Updated conversation #{conversation.id}"
              break
            end
          end
        end

        puts "Skipping conversation #{conversation.id}" unless match_found

      end
    end
  end

  def down
    #No need to remove the old ones
  end
end
