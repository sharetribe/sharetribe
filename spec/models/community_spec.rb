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

    def get_listing(created_at, updates_email_at)
      FactoryGirl.create(:listing,
        :created_at => created_at.days.ago,
        :updates_email_at => updates_email_at.days.ago,
        :communities => [@community])
    end

    before(:each) do
      @p1 = FactoryGirl.create(:person, :emails => [ FactoryGirl.create(:email, :address => "update_tester@example.com") ])
      @p1.communities << @community
      @l1 = get_listing(2,2)
      @l2 = get_listing(3,3)
      @l3 = get_listing(12,12)
      @l4 = get_listing(13,3)
    end

    it "should contain latest and picked listings" do
      listings_to_email = @community.get_new_listings_to_update_email(@p1)

      listings_to_email.should include(@l1, @l2, @l4)
      listings_to_email.should_not include(@l3)
    end
    it "should prioritize picked listings" do
      @l5 = get_listing(13,3)
      @l6 = get_listing(13,3)
      @l7 = get_listing(13,3)
      @l8 = get_listing(13,3)
      @l9 = get_listing(13,3)
      @l10 = get_listing(13,3)
      @l11 = get_listing(13,3)
      @l12 = get_listing(13,3)

      listings_to_email = @community.get_new_listings_to_update_email(@p1)

      listings_to_email.should include(@l1, @l4, @l5, @l6, @l7, @l8, @l9, @l10, @l11, @l12)
      listings_to_email.should_not include(@l2, @l3)
    end

    it "should include just picked listings" do
      @l5 = get_listing(13,3)
      @l6 = get_listing(13,3)
      @l7 = get_listing(13,3)
      @l8 = get_listing(13,3)
      @l9 = get_listing(13,3)
      @l10 = get_listing(13,3)
      @l11 = get_listing(13,3)
      @l12 = get_listing(13,3)
      @l13 = get_listing(13,3)
      @l14 = get_listing(13,3)

      listings_to_email = @community.get_new_listings_to_update_email(@p1)

      listings_to_email.should include(@l4, @l5, @l6, @l7, @l8, @l9, @l10, @l11, @l12, @l13,@l14)
      listings_to_email.should_not include(@l1, @l2, @l3)
    end
  end
end

