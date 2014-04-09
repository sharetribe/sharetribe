require 'spec_helper'

describe Notification do

  before(:each) do
    @test_person = FactoryGirl.create(:person)
    @notification = FactoryGirl.create(:notification, :receiver => @test_person)
  end

  it "is only valid with valid notification types" do
    @notification.should be_valid
    Notification::VALID_NOTIFIABLE_TYPES.each do |type|
      @notification.notifiable_type = type
      @notification.should be_valid
    end
    @notification.notifiable_type = "test"
    @notification.should_not be_valid
  end

  it "is not valid without notifiable_id" do
    @notification.notifiable_id = nil
    @notification.should_not be_valid
  end

  it "is not valid without notifiable_type" do
    @notification.notifiable_type = nil
    @notification.should_not be_valid
  end

  it "is valid without description" do
    @notification.description = nil
    @notification.should be_valid
  end

  it "is not valid if the same notification already exists" do
    @notification.should be_valid
    @notification2 = FactoryGirl.build(:notification, :receiver => @test_person)
    @notification2.should_not be_valid
    @notification.update_attribute(:created_at, 25.hours.ago)
    @notification2.should be_valid
  end

end
