require 'spec_helper'
require 'admin/community_invitations_controller'

describe Admin::CommunityInvitationsController, type: :controller do
  let(:community) { FactoryGirl.create(:community) }

  before(:each) do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    user = create_admin_for(community)
    sign_in_for_spec(user)
  end

  describe '#index' do
    let(:inviter1) { FactoryGirl.create(:person, community_id: community.id, given_name: 'Dawn', family_name: 'Jones') }
    let(:inviter2) { FactoryGirl.create(:person, community_id: community.id, given_name: 'Tracy', family_name: 'Miler') }
    let(:invitee2) { FactoryGirl.create(:person, community_id: community.id, given_name: 'Ethel', family_name: 'Harris') }
    let(:invitation1) do
      FactoryGirl.create(:invitation, community: community, inviter: inviter1, message: 'Hi, Megan!',
                                      email: 'megan@example.com', usages_left: 1, created_at: Time.current - 1.minute)
    end
    let(:invitation2) do
      invitation = FactoryGirl.create(:invitation, community: community, inviter: inviter2,
                                                   message: 'Hi, Ethel!',
                                                   email: 'ethel@example.com', usages_left: 0)
      FactoryGirl.create(:community_membership, community: community, person: invitee2,
                                                invitation_id: invitation.id)
      invitation
    end

    it 'shows invitations' do
      invitation1
      invitation2
      get :index, params: {community_id: community.id}
      invitations = assigns(:service).invitations
      expect(invitations.size).to eq 2
      expect(invitations.first).to eq invitation2
      expect(invitations.last).to eq invitation1
    end

    it 'shows sort invitations' do
      invitation1
      invitation2
      get :index, params: {community_id: community.id, sort: 'sent_by', direction: 'asc'}
      invitations = assigns(:service).invitations
      expect(invitations.first).to eq invitation1
      expect(invitations.last).to eq invitation2
      get :index, params: {community_id: community.id, sort: 'sent_by', direction: 'desc'}
      invitations = assigns(:service).invitations
      expect(invitations.first).to eq invitation2
      expect(invitations.last).to eq invitation1
      get :index, params: {community_id: community.id, sort: 'sent_to', direction: 'asc'}
      invitations = assigns(:service).invitations
      expect(invitations.first).to eq invitation2
      expect(invitations.last).to eq invitation1
      get :index, params: {community_id: community.id, sort: 'sent_to', direction: 'desc'}
      invitations = assigns(:service).invitations
      expect(invitations.first).to eq invitation1
      expect(invitations.last).to eq invitation2
      get :index, params: {community_id: community.id, sort: 'used', direction: 'asc'}
      invitations = assigns(:service).invitations
      expect(invitations.first).to eq invitation2
      expect(invitations.last).to eq invitation1
      get :index, params: {community_id: community.id, sort: 'used', direction: 'desc'}
      invitations = assigns(:service).invitations
      expect(invitations.first).to eq invitation1
      expect(invitations.last).to eq invitation2
    end
  end
end
