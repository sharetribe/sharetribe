# == Schema Information
#
# Table name: contact_requests
#
#  id               :integer          not null, primary key
#  email            :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  country          :string(255)
#  plan_type        :string(255)
#  marketplace_type :string(255)
#

require 'spec_helper'

describe ContactRequest do

  before(:each) do
    @contact_request = FactoryGirl.build(:contact_request)
  end

  it "is valid with valid attributes" do
    @contact_request.should be_valid
  end

end
