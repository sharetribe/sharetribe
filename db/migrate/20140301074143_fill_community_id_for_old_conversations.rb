class FillCommunityIdForOldConversations < ActiveRecord::Migration
  def up
    Conversation.find_each do |conversation|
      if conversation.community_id.nil?
        first_participant_communities = conversation.participants.first.communities
        second_participants_communities = conversation.participants.last.communities

        second_participants_communities.each do |community|
          if first_participant_communities.include?(community)
            # match found
            match = true
            conversation.update_column(:community_id, community.id)
          end
        end

        if match_
      end
    end
  end

  def down
    #No need to remove the old ones
  end
end
