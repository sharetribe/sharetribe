require 'spec_helper'

# Disable badges for now

# describe Badge do

#   before(:each) do
#     @badge = FactoryGirl.build(:badge)
#   end

#   it "is valid with valid attributes" do
#     @badge.should be_valid
#   end

#   it "is not valid without name" do
#     @badge.name = nil
#     @badge.should_not be_valid
#   end

#   it "is not valid if the person already has the same badge" do
#     @test_person, @session = get_test_person_and_session
#     @badge1 = FactoryGirl.create(:badge, :person => @test_person)
#     @badge2 = FactoryGirl.build(:badge, :person => @test_person)
#     @badge2.should_not be_valid
#   end

#   it "is only valid if name is one of the valid names" do
#     @badge.name = "test"
#     @badge.should_not be_valid
#     Badge::UNIQUE_BADGES.each do |name|
#       @badge.name = name
#       @badge.should be_valid
#     end
#   end

# end
