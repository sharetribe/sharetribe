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
        FactoryGirl.create(:message, :conversation => @con1, :sender => @p1, :content => "Let's talk")
        FactoryGirl.create(:message, :conversation => @con1, :sender => @p2, :content => "Ok! You start.")

      end
    
    
    describe "index" do
    
      it "returns the persons conversations if called without parameters, (paginated by 50)" do
        request.env['Sharetribe-API-Token'] = @p1.authentication_token
        get :index, :person_id => @p1.id, :format => :json
        response.status.should == 200
        resp = JSON.parse(response.body)
        #puts resp.to_yaml
        resp["conversations"].count.should == 1
        resp["conversations"][0]["last_message"].should_not be_nil
        resp["page"].should == 1
        resp["per_page"].should == 50
      end
      
    end
    
    describe "show" do
      it "returns the messages of a single conversation" do
        request.env['Sharetribe-API-Token'] = @p1.authentication_token
        get :show, :person_id => @p1.id, :id => @con1.id, :format => :json
        response.status.should == 200
        resp = JSON.parse(response.body)
        
        #puts response.body
        #puts resp.to_yaml
        resp["messages"].count.should == 2
        resp["messages"][0]["content"].should == "Let's talk"
        resp["messages"][1]["content"].should == "Ok! You start."
      end
      
    end
    
    describe "create" do
      it "creates a new conversation" do
        request.env['Sharetribe-API-Token'] = @p1.authentication_token
        post :create, :person_id => @p1.id, 
                      :target_person_id => @p2.id,
                      :listing_id => @l1.id,
                      :status => "pending",
                      :content => "This will be the first message of the conversation",
                      :community_id => @c1.id,
                      :format => :json
        response.status.should == 201
        resp = JSON.parse(response.body)
        #puts response.body
        #puts resp.to_yaml
        #check that title is done automatically
        resp["title"].should == "Item offer: Sledgehammer"
        resp["messages"].count.should == 1
        resp["messages"][0]["content"].should == "This will be the first message of the conversation"
        resp["messages"][0]["sender_id"].should == @p1.id
        resp["status"].should == "pending"
        [@p1.id, @p2.id].should include(resp["participations"][0]["person"]["id"])
        [@p1.id, @p2.id].should include(resp["participations"][1]["person"]["id"])
        resp["participations"][1]["person"]["id"].should_not == resp["participations"][0]["person"]["id"]
      end
    end
    
    describe "new_message" do
      it "adds a message to the conversation" do
        request.env['Sharetribe-API-Token'] = @p1.authentication_token
        post :new_message, :id => @con1.id, 
                           :person_id => @p1.id,
                           :community_id => @c1.id,
                           :content => "I'd like to continue this topic",
                           :format => :json
        response.status.should == 201
        #puts response.body
        resp = JSON.parse(response.body)
        #puts resp.to_yaml
        resp["title"].should == "Item offer: Sledgehammer"
        resp["messages"].count.should == 3
        resp["messages"][2]["content"].should == "I'd like to continue this topic"
        resp["messages"][2]["sender_id"].should == @p1.id
        resp["status"].should == "pending"
        resp["participations"][0]["person"]["id"].should == @p1.id
        resp["participations"][1]["person"]["id"].should == @p2.id
      end
    end



  end
end