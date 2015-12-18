require 'spec_helper'

describe Admin::CommunityMembershipsController do
  before(:each) do
    @community = FactoryGirl.create(:community)
    @request.host = "#{@community.ident}.lvh.me"
    @person = create_admin_for(@community)
    @other_email = FactoryGirl.create(:email, person: @person)
    sign_in_for_spec(@person)
  end

  describe "users CSV export" do
    it "returns 200" do
      get :index, {format: :csv, community_id: @community.id}
      response.status.should == 200
    end

    it "returns CSV with actual data" do
      get :index, {format: :csv, community_id: @community.id}
      response_arr = CSV.parse(response.body)
      response_arr.count.should == 3
      user = Hash[*response_arr[0].zip(response_arr[1]).flatten]
      user2 = Hash[*response_arr[0].zip(response_arr[2]).flatten]

      user["first_name"].should == @person.given_name
      user["last_name"].should == @person.family_name
      user["phone_number"].should == @person.phone_number
      user["email_address"].should == @person.emails.first.address
      user["status"].should == "accepted"

      user2["first_name"].should == @person.given_name
      user2["last_name"].should == @person.family_name
      user2["phone_number"].should == @person.phone_number
      user2["email_address"].should == @other_email.address
      user2["status"].should == "accepted"
    end
  end
end

describe Admin::CommunityTransactionsController do
  before(:each) do
    @community = FactoryGirl.create(:community)
    @person = create_admin_for(@community)
    @listing = FactoryGirl.create(:listing, community_id: @community.id, transaction_process_id: 123, author: @person)
    sign_in_for_spec(@person)
    @request.host = "#{@community.ident}.lvh.me"
    @transaction = FactoryGirl.create(:transaction, starter: @person, listing: @listing, community: @community)

    FeatureFlagService::API::Api.features.enable(community_id: @community.id, features: [:export_transactions_as_csv])
  end

  describe "transactions CSV export" do
    it "returns 200" do
      get :index, {format: :csv, per_page: 99999, community_id: @community.id}
      response.status.should == 200
    end

    it "returns CSV with actual data" do
      get :index, {format: :csv, per_page: 99999, community_id: @community.id}
      response_arr = CSV.parse(response.body)
      tx = Hash[*response_arr[0].zip(response_arr[1]).flatten]

      tx["listing_id"] = @listing.id
      tx["listing_name"] = @listing.title
      tx["transaction_id"] = @transaction.id
      tx["starter_username"] = @person.username
    end
  end
end
