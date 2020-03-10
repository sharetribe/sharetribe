require 'spec_helper'

describe Admin2::Users::ManageUsersController, type: :controller do
  let(:community) { FactoryGirl.create(:community) }
  let(:person1) { FactoryGirl.create(:person, member_of: community) }
  let(:person2) { FactoryGirl.create(:person, member_of: community) }
  let(:person_with_unconfirmed_email) do
    person = FactoryGirl.create(:person, member_of: community)
    email = person.emails.first
    email.update_column(:confirmed_at, nil)
    person.community_membership.update_column(:status, CommunityMembership::PENDING_EMAIL_CONFIRMATION)
    person
  end
  let(:person_with_pending_consent) do
    person = FactoryGirl.create(:person, member_of: community)
    person.community_membership.update_column(:status, CommunityMembership::PENDING_CONSENT)
    person
  end
  let(:person_banned) do
    person = FactoryGirl.create(:person, member_of: community)
    person.community_membership.update(status: "banned")
    person
  end

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

    it 'filters admin' do
      person1
      person2
      get :index, params: {community_id: community.id, status: ['admin']}
      service = assigns(:service)
      memberships = service.memberships
      expect(memberships.size).to eq 1
    end

    it 'filters banned' do
      membership1 = person1.community_membership
      membership1.update_column(:status, 'banned')
      person2
      get :index, params: {community_id: community.id, status: ['banned']}
      service = assigns(:service)
      memberships = service.memberships
      expect(memberships.size).to eq 1
    end

    it 'filters posting_allowed' do
      membership1 = person1.community_membership
      membership1.update_column(:can_post_listings, true)
      person2
      get :index, params: {community_id: community.id, status: ['posting_allowed']}
      service = assigns(:service)
      memberships = service.memberships
      expect(memberships.size).to eq 1
    end

    it 'filters admin or banned' do
      person1
      membership1 = person2.community_membership
      membership1.update_column(:status, 'banned')
      get :index, params: {community_id: community.id, status: ['admin', 'banned']}
      service = assigns(:service)
      memberships = service.memberships
      expect(memberships.size).to eq 2
    end

    it 'filters admin or banned or posting_allowed' do
      membership1 = person1.community_membership
      membership1.update_column(:can_post_listings, true)
      membership1 = person2.community_membership
      membership1.update_column(:status, 'banned')
      get :index, params: {community_id: community.id, status: ['admin', 'banned', 'posting_allowed']}
      service = assigns(:service)
      memberships = service.memberships
      expect(memberships.size).to eq 3
    end

    it 'filters unconfirmed' do
      person1
      person_with_unconfirmed_email
      get :index, params: {community_id: community.id, status: ['unconfirmed']}
      service = assigns(:service)
      memberships = service.memberships
      expect(memberships.size).to eq 1
    end

    it 'filters pending' do
      person1
      person_with_pending_consent
      get :index, params: {community_id: community.id, status: ['pending']}
      service = assigns(:service)
      memberships = service.memberships
      expect(memberships.size).to eq 1
    end

    it 'filters accepted' do
      person1
      person_with_pending_consent
      get :index, params: {community_id: community.id, status: ['accepted']}
      service = assigns(:service)
      memberships = service.memberships
      expect(memberships.size).to eq 2
    end
  end

  describe "#ban" do
    it 'works' do
      membership = person1.community_membership
      expect(membership.status).to eq 'accepted'
      patch :ban, params: {community_id: community.id, id: membership.id}, xhr: true
      membership.reload
      expect(membership.status).to eq 'banned'
    end
  end

  describe "#unban" do
    it 'works' do
      membership = person1.community_membership
      membership.update_column(:status, 'banned')
      expect(membership.status).to eq 'banned'
      patch :unban, params: {community_id: community.id, id: membership.id}, xhr: true
      membership.reload
      expect(membership.status).to eq 'accepted'
    end
  end

  describe "#promote_admin" do
    it 'works' do
      membership = person1.community_membership
      expect(membership.admin).to eq false
      post :promote_admin, params: {id: membership.id, add_admin: person1.id}, xhr: true
      membership.reload
      expect(membership.admin).to eq true
      post :promote_admin, params: {id: membership.id, remove_admin: person1.id}, xhr: true
      membership.reload
      expect(membership.admin).to eq false
    end
  end

  describe "#posting_allowed" do
    it 'works' do
      membership = person1.community_membership
      expect(membership.can_post_listings).to eq false
      post :posting_allowed, params: {id: membership.id, allowed_to_post: person1.id}, xhr: true
      membership.reload
      expect(membership.can_post_listings).to eq true
      post :posting_allowed, params: {id: membership.id, disallowed_to_post: person1.id}, xhr: true
      membership.reload
      expect(membership.can_post_listings).to eq false
    end
  end

  describe "#resend_confirmation" do
    it 'works' do
      person = person_with_unconfirmed_email
      membership = person.community_membership
      ActionMailer::Base.deliveries.clear
      put :resend_confirmation, params: {community_id: community.id, id: membership.id}, xhr: true
      Delayed::Worker.new.work_off
      expect(ActionMailer::Base.deliveries.count).to eq 1
      delivered_email = ActionMailer::Base.deliveries.last
      expect(delivered_email.to).to eq [person.emails.first.address]
    end
  end

  describe "#destroy" do
    it 'works' do
      membership = person_banned.community_membership
      delete :destroy, params: {id: membership.id, format: :js}
      person_banned.reload
      expect(person_banned.deleted).to eq true
    end

    it 'does not delete if person is not banned' do
      membership = person1.community_membership
      delete :destroy, params: {id: membership.id, format: :js}
      person1.reload
      expect(person1.deleted).to eq false
    end
  end

end
