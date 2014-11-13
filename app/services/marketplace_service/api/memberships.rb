module MarketplaceService::API

  module Memberships

    module_function

    def make_user_a_member_of_community(user_id, community_id, invitation_id=nil)

      # Fetching the models would not be necessary, but that validates the ids
      user = Person.find(user_id)
      community = Community.find(community_id)

      membership = CommunityMembership.new(:person => user, :community => community, :consent => community.consent)
      membership.status = "pending_email_confirmation"
      membership.invitation = Invitation.find(invitation_id) if invitation_id.present?

      # If the community doesn't have any members, make the first one an admin
      if community.members.count == 0
        membership.admin = true
      end
      membership.save!
    end

  end
end
