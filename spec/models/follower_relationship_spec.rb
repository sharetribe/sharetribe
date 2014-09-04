# == Schema Information
#
# Table name: follower_relationships
#
#  id          :integer          not null, primary key
#  person_id   :string(255)      not null
#  follower_id :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_follower_relationships_on_follower_id                (follower_id)
#  index_follower_relationships_on_person_id                  (person_id)
#  index_follower_relationships_on_person_id_and_follower_id  (person_id,follower_id) UNIQUE
#

require 'spec_helper'

describe FollowerRelationship do
  
  before(:each) do
    @follower_relationship = FactoryGirl.create(:follower_relationship)
    @person = @follower_relationship.person
    @follower = @follower_relationship.follower
  end
  
  it "should include the follower in the person's follower list" do
    @person.followers.should include @follower
  end
  
  it "should not include the person in the follower's follower list" do
    @follower.followers.should_not include @person
  end
  
  it "should include the person in the follower's followed people list" do
    @follower.followed_people.should include @person
  end
  
  it "should not include the follower in the person's followed people list" do
    @person.followed_people.should_not include @follower
  end
  
  it "should not allow a duplicate follower relationship" do
    duplicate_attributes = @follower_relationship.attributes.slice(:person_id, :follower_id)
    FollowerRelationship.new(duplicate_attributes).should_not be_valid
  end
  
  it "should allow an inverse follower relationship" do
    inverse_attributes = { 
      :person_id => @follower_relationship.follower_id, 
      :follower_id => @follower_relationship.person_id 
    }
    FollowerRelationship.new(inverse_attributes).should be_valid
  end
  
  it "should not allow a person to follow themselves" do
    self_attributes = {  
      :person_id => @follower_relationship.person_id,
      :follower_id => @follower_relationship.person_id
    }
    FollowerRelationship.new(self_attributes).should_not be_valid
  end
end
