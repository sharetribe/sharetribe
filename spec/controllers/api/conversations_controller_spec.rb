require 'spec_helper'

describe Api::ConversationsController do
  if not use_asi? # No need to run the API tests with ASI
    
     before(:each) do
        Listing.all.collect(&:destroy) # for some reason there's a listing before starting. Destroy to be clear.

        @c1 = FactoryGirl.create(:community)
        @l1 = FactoryGirl.create(:listing)
        @l1.communities = [@c1]

        @p1 = FactoryGirl.create(:person)
        @p1.communities << @c1
        @p2 = FactoryGirl.create(:person)
        @p2.communities << @c1
        @p1.ensure_authentication_token!
        
        @con1 = FactoryGirl.create(:conversation, :participants => [@p1, @p2])
        FactoryGirl.create(:message, :conversation => @con1, :sender => @p1)
        FactoryGirl.create(:message, :conversation => @con1, :sender => @p2)

      end
    
    
    describe "index" do
    
      it "returns the persons conversations if called without parameters, (paginated by 50)" do
        request.env['Sharetribe-API-Token'] = @p1.authentication_token
        get :index, :person_id => @p1.id, :format => :json
        response.status.should == 200
        resp = JSON.parse(response.body)
        puts response.body
        #resp["conversations"].count.should == 3
        resp["page"].should == 1
        resp["per_page"].should == 50
      end
      
    end



  end
end