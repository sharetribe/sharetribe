# encoding: UTF-8

require 'spec_helper'

describe Community do

  before(:each) do
    @community = FactoryGirl.build(:community)
  end

  it "is valid with valid attributes" do
    @community.should be_valid
  end

  it "is not valid without proper name" do
    @community.name = nil
    @community.should_not be_valid
    @community.name = "a"
    @community.should_not be_valid
    @community.name = "a" * 51
    @community.should_not be_valid
  end

  it "is not valid without proper domain" do
    @community.domain = "test_community-9"
    @community.should be_valid
    @community.domain = nil
    @community.should_not be_valid
    @community.domain = "a"
    @community.should_not be_valid
    @community.domain = "a" * 51
    @community.should_not be_valid
    @community.domain = "´?€"
    @community.should_not be_valid
  end

  it "validates twitter handle" do
    @community.twitter_handle = "abcdefghijkl"
    @community.should be_valid
    @community.twitter_handle = "abcdefghijklmnopqr"
    @community.should_not be_valid
    @community.twitter_handle = "@abcd"
    @community.should_not be_valid
    @community.twitter_handle = "AbCd1"
    @community.should be_valid
  end


  describe "#get_new_listings_to_update_email" do

    before(:each) do
      @p1 = FactoryGirl.create(:person, :emails => [ FactoryGirl.create(:email, :address => "update_tester@example.com") ])
      @p1.communities << @community
      @l1 = FactoryGirl.create(:listing,
          :transaction_type => FactoryGirl.create(:transaction_type_request),
          :title => "bike",
          :description => "A very nice bike",
          :created_at => 3.days.ago,
          :updates_email_at => 3.days.ago,
          :author => @p1,
          :communities => [@community])
      @l2 = FactoryGirl.create(:listing,
          :title => "hammer",
          :created_at => 2.days.ago,
          :updates_email_at => 2.days.ago,
          :description => "<b>shiny</b> new hammer, see details at http://en.wikipedia.org/wiki/MC_Hammer",
          :transaction_type => FactoryGirl.create(:transaction_type_sell),
          :communities => [@community])
      @l3 = FactoryGirl.create(:listing,
          :title => "sledgehammer",
          :created_at => 12.days.ago,
          :updates_email_at => 12.days.ago,
          :description => "super <b>shiny</b> sledgehammer, borrow it!",
          :transaction_type => FactoryGirl.create(:transaction_type_lend),
          :communities => [@community])

      @l4 = FactoryGirl.create(:listing,
          :title => "skateboard",
          :created_at => 13.days.ago,
          :updates_email_at => 3.days.ago,
          :description => "super <b>dirty</b> skateboard!",
          :transaction_type => FactoryGirl.create(:transaction_type_lend),
          :communities => [@community])
    end

    it "should contain latest and picked listings" do
      listings_to_email = @community.get_new_listings_to_update_email(@p1)

      listings_to_email.should include(@l1)
      listings_to_email.should_not include(@l3)
    end
  end
end

