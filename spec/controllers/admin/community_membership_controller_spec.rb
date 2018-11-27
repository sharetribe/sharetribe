require 'spec_helper'

describe Admin::CommunityMembershipsController, type: :controller do
  let(:community) { FactoryGirl.create(:community) }
  let(:person1) { FactoryGirl.create(:person, member_of: community) }
  let(:person2) { FactoryGirl.create(:person, member_of: community) }

  before(:each) do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    user = create_admin_for(community)
    sign_in_for_spec(user)
  end

  describe "#index" do
    it 'works' do
      person1
      person2
      get :index, params: {community_id: community.id}
      service = assigns(:service)
      memberships = service.memberships
      expect(memberships.size).to eq 3
    end
  end

  describe "#ban" do
    it 'works' do
      membership = person1.community_memberships.where(community: community).first
      expect(membership.status).to eq 'accepted'
      get :ban, params: {community_id: community.id, id: membership.id}
      membership.reload
      expect(membership.status).to eq 'banned'
    end
  end

  describe "#unban" do
    it 'works' do
      membership = person1.community_memberships.where(community: community).first
      membership.update_column(:status, 'banned')
      expect(membership.status).to eq 'banned'
      get :unban, params: {community_id: community.id, id: membership.id}
      membership.reload
      expect(membership.status).to eq 'accepted'
    end
  end

  describe "#promote_admin" do
    it 'works' do
      membership = person1.community_memberships.where(community: community).first
      expect(membership.admin).to eq false
      get :promote_admin, params: {community_id: community.id, add_admin: person1.id}
      membership.reload
      expect(membership.admin).to eq true
      get :promote_admin, params: {community_id: community.id, remove_admin: person1.id}
      membership.reload
      expect(membership.admin).to eq false
    end
  end

  describe "#posting_allowed" do
    it 'works' do
      membership = person1.community_memberships.where(community: community).first
      expect(membership.can_post_listings).to eq false
      get :posting_allowed, params: {community_id: community.id, allowed_to_post: person1.id}
      membership.reload
      expect(membership.can_post_listings).to eq true
      get :posting_allowed, params: {community_id: community.id, disallowed_to_post: person1.id}
      membership.reload
      expect(membership.can_post_listings).to eq false
    end
  end
end
