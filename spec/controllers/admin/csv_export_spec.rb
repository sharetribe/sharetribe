require 'spec_helper'

describe Admin::CommunityMembershipsController, type: :controller do
  before(:each) do
    @community = FactoryGirl.create(:community)
    @request.host = "#{@community.ident}.lvh.me"
    @request.env[:current_marketplace] = @community
    @person = create_admin_for(@community)
    @other_email = FactoryGirl.create(:email, person: @person)
    sign_in_for_spec(@person)
  end

  describe "users CSV export" do
    it "returns 200" do
      get :index, params: {format: :csv, community_id: @community.id}
      expect(response.status).to eq(200)
    end

    it "returns CSV with actual data" do
      get :index, params: {format: :csv, community_id: @community.id} 
      response_arr = CSV.parse(response.body)
      expect(response_arr.count).to eq(3)
      user = Hash[*response_arr[0].zip(response_arr[1]).flatten]
      user2 = Hash[*response_arr[0].zip(response_arr[2]).flatten]

      expect(user["first_name"]).to eq(@person.given_name)
      expect(user["last_name"]).to eq(@person.family_name)
      expect(user["display_name"]).to eq(@person.display_name || "")
      expect(user["phone_number"]).to eq(@person.phone_number)
      expect(user["email_address"]).to eq(@person.emails.first.address)
      expect(user["status"]).to eq("accepted")

      expect(user2["first_name"]).to eq(@person.given_name)
      expect(user2["last_name"]).to eq(@person.family_name)
      expect(user2["display_name"]).to eq(@person.display_name || "")
      expect(user2["phone_number"]).to eq(@person.phone_number)
      expect(user2["email_address"]).to eq(@other_email.address)
      expect(user2["status"]).to eq("accepted")
    end
  end
end

describe Admin::CommunityTransactionsController, type: :controller do
  before(:each) do
    # the @request is shared between test groups here so clear the request store
    RequestStore.clear!

    @community = FactoryGirl.create(:community)
    @person = create_admin_for(@community)
    @listing = FactoryGirl.create(:listing, community_id: @community.id, transaction_process_id: 123, author: @person)
    sign_in_for_spec(@person)
    @request.host = "#{@community.ident}.lvh.me"
    @request.env[:current_marketplace] = @community
    @transaction = FactoryGirl.create(:transaction, starter: @person, listing: @listing, community: @community)
  end

  describe "transactions CSV export" do
    it "returns 200" do
      get :index, params: {format: :csv, per_page: 99999, community_id: @community.id}
      expect(response.status).to eq(200)
    end

    it "returns CSV with actual data" do
      get :index, params: {format: :csv, per_page: 99999, community_id: @community.id}
      response_arr = CSV.parse(response.body)
      tx = Hash[*response_arr[0].zip(response_arr[1]).flatten]

      tx["listing_id"] = @listing.id
      tx["listing_name"] = @listing.title
      tx["transaction_id"] = @transaction.id
      tx["starter_username"] = @person.username
    end
  end
end
