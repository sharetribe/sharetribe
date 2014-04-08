require 'spec_helper'

describe Email do
  describe "before_save" do
    it "downcases address" do
      e = Email.create(:address => "TeST@eXample.COM", :person => FactoryGirl.create(:person))
      Email.find(e.id).address.should == "test@example.com"
    end
  end
end
