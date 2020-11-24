require 'spec_helper'

describe Admin2::Users::UserRightsController, type: :controller do
  let(:community) do
    community = FactoryGirl.create(:community,
                        join_with_invite_only: false,
                        users_can_invite_new_users: false,
                        require_verification_to_post_listings: false,
                        allow_free_conversations: false)
    community
  end

  before(:each) do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    user = create_admin_for(community)
    sign_in_for_spec(user)
  end

  describe "#update_user_rights" do
    it "works" do
      params = {
        join_with_invite_only: true,
        users_can_invite_new_users: true,
        require_verification_to_post_listings: true,
        allow_free_conversations: true
      }

      expect(community.join_with_invite_only).to eq false
      expect(community.users_can_invite_new_users).to eq false
      expect(community.require_verification_to_post_listings).to eq false
      expect(community.allow_free_conversations).to eq false

      put :update_user_rights, params: { community: params }
      community.reload

      expect(community.join_with_invite_only).to eq true
      expect(community.users_can_invite_new_users).to eq true
      expect(community.require_verification_to_post_listings).to eq true
      expect(community.allow_free_conversations).to eq true
    end
  end
end
