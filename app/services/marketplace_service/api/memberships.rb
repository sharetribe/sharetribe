module MarketplaceService::API

  module Memberships

    module_function

    def make_user_a_member_of_community(user, community, invitation=nil)
      membership = CommunityMembership.new(:person => user, :community => community, :consent => community.consent)
      membership.status = "pending_email_confirmation"
      membership.invitation = invitation if invitation.present?
      # If the community doesn't have any members, make the first one an admin
      if community.members.count == 0
        membership.admin = true
      end
      membership.save!
    end

  end
end
