require 'spec_helper'

describe EmailsController do
  describe "#destroy" do
    before(:each) do
      @community = FactoryGirl.create(:community)
      @request.host = "#{@community.domain}.lvh.me"
    end

    it "should destroy email" do
      person = FactoryGirl.create(:person)
      person.emails = [
        FactoryGirl.create(:email, :address => "one@examplecompany.co", :send_notifications => true),
        FactoryGirl.create(:email, :address => "two@examplecompany.co", :send_notifications => true)
      ]
      person.save!

      @community.members << person
      sign_in_for_spec(person)

      Email.find_all_by_person_id(person.id).count.should == 2

      delete :destroy, {:person_id => person.id, :id => person.emails.first.id}

      Email.find_all_by_person_id(person.id).count.should == 1
      response.status.should == 302
    end

    it "should not destroy email if that's not allowed" do
      # Don't test all edge cases here. They are covered in specs
      person = FactoryGirl.create(:person)
      person.emails = [
        FactoryGirl.create(:email, :address => "one@examplecompany.co", :send_notifications => true),
        FactoryGirl.create(:email, :address => "two@examplecompany.co", :send_notifications => false)
      ]
      person.save!

      @community.members << person
      sign_in_for_spec(person)

      Email.find_all_by_person_id(person.id).count.should == 2

      delete :destroy, {:person_id => person.id, :id => person.emails.first.id}

      Email.find_all_by_person_id(person.id).count.should == 2
      response.status.should == 302
    end
  end
end
