require 'spec_helper'

describe CommunityMembership do
  
  before(:each) do
    @community_membership = Factory.build(:community_membership)
  end
  
  it "is valid with valid attributes" do
    @community_membership.should be_valid
  end
  
end
