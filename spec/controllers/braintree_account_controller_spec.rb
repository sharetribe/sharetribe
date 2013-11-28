require 'spec_helper'

describe BraintreeAccountController do
  describe "#create" do
    before(:each) do
      @community = FactoryGirl.create(:community)
      @request.host = "#{@community.domain}.lvh.me"
      @person = FactoryGirl.create(:person)
      @community.members << @person
      sign_in_for_spec(@person)
    end

    it "should create braintree details" do
      post :create, :braintree_account => {:person_id => @person.id, :first_name => "Joe", :last_name => "Bloggs"}
      
      response.status.should == 302

      braintree_account = BraintreeAccount.find_by_person_id(@person.id)
      braintree_account.first_name.should be_eql("Joe")
      braintree_account.last_name.should be_eql("Bloggs")
    end
  end
end