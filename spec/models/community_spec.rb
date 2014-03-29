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
  
end
