require 'spec_helper'

describe Api::ConversationsController do
  render_views

  
   before(:each) do
      pending("API tests are pending")
      Listing.all.collect(&:destroy) # for some reason there's a listing before starting. Destroy to be clear.

      @c1 = FactoryGirl.create(:community)
      @l1 = FactoryGirl.create(:listing)
      @l1.communities = [@c1]

      @p1 = FactoryGirl.create(:person)
      @p1.communities << @c1
      @p2 = FactoryGirl.create(:person)
      @p2.communities << @c1
      @p1.ensure_authentication_token!
              
      
      @con2 = FactoryGirl.create(:conversation, :participants => [@p1, @p2], :last_message_at => 2.day.ago, :title  => "second thoughts")
      FactoryGirl.create(:message, :conversation => @con2, :sender => @p1, :content => "This is another conversation", :created_at => 3.days.ago)
      FactoryGirl.create(:message, :conversation => @con2, :sender => @p2, :content => "Yep, so it seems.", :created_at => 2.days.ago)
      
      @con1 = FactoryGirl.create(:conversation, :participants => [@p1, @p2], :last_message_at => 1.day.ago)
      FactoryGirl.create(:message, :conversation => @con1, :sender => @p1, :content => "Let's talk", :created_at => 1.day.ago)
      FactoryGirl.create(:message, :conversation => @con1, :sender => @p2, :content => "Ok! You start.")

    end
  
  
  describe "index" do
  
    it "returns the persons conversations if called without parameters, (paginated by 50)" do
      request.env['Sharetribe-API-Token'] = @p1.authentication_token
      get :index, :person_id => @p1.id, :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)
      #puts response.body
      #puts resp.to_yaml
      resp["conversations"].count.should == 2
      resp["conversations"][0]["last_message"].should_not be_nil
      resp["conversations"][1]["last_message"].should_not be_nil
      resp["conversations"][1]["title"].should == "second thoughts"
      
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
      @l1.listing_type.should == "offer"
      #puts response.body
      #puts resp.to_yaml
      #check that title is done automatically
      resp["title"].should == "Sledgehammer"
      resp["messages"].count.should == 1
      resp["messages"][0]["content"].should == "This will be the first message of the conversation"
      resp["messages"][0]["sender_id"].should == @p1.id
      resp["status"].should == "pending"
      [@p1.id, @p2.id].should include(resp["participations"][0]["person"]["id"])
      [@p1.id, @p2.id].should include(resp["participations"][1]["person"]["id"])
      resp["participations"][1]["person"]["id"].should_not == resp["participations"][0]["person"]["id"]
    end
    
    it "doesn't allow messaging yourself" do
      request.env['Sharetribe-API-Token'] = @p1.authentication_token
      post :create, :person_id => @p1.id, 
                    :target_person_id => @p1.id,
                    :status => "free",
                    :content => "I'm trying to message myself",
                    :community_id => @c1.id,
                    :format => :json
      response.status.should == 400
      resp = JSON.parse(response.body)        
      resp[0].should == "You cannot send message to yourself."
    end
    
    it "handles requests with invalid listing_id" do
      request.env['Sharetribe-API-Token'] = @p1.authentication_token
      post :create, :person_id => @p1.id, 
                    :target_person_id => @p2.id,
                    :listing_id => 123456789,
                    :status => "pending",
                    :content => "I'm trying to respond to nonexisting listing",
                    :community_id => @c1.id,
                    :format => :json
      response.status.should == 404
      resp = JSON.parse(response.body)        
      resp[0].should == "No listing found with given id"
      
    end
  end
  
  describe "new_message" do
    it "adds a message to the conversation" do
      request.env['Sharetribe-API-Token'] = @p1.authentication_token
      #puts "This test might fail about 'Devise::Mailer' if run with spork."
      post :new_message, :id => @con1.id, 
                         :person_id => @p1.id,
                         :community_id => @c1.id,
                         :content => "I'd like to continue this topic",
                         :format => :json
      response.status.should == 201
      assert !ActionMailer::Base.deliveries.empty?
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

  describe "update" do
    it "changes the conversation status" do
      request.env['Sharetribe-API-Token'] = @p1.authentication_token
      put :update, :id => @con1.id, 
                         :person_id => @p1.id,
                         :community_id => @c1.id,
                         :status => "rejected",
                         :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)
      resp["status"].should == "rejected"
    end
    
    it "doesn't allow invalid status" do
      request.env['Sharetribe-API-Token'] = @p1.authentication_token
      put :update, :id => @con1.id, 
                         :person_id => @p1.id,
                         :community_id => @c1.id,
                         :status => "waiting",
                         :format => :json
      response.status.should == 400
      resp = JSON.parse(response.body)
      resp[0].should == "The conversation status (waiting) is not valid."
    end
    
    it "doesn't allow outsider person to change status" do
      @p3 = FactoryGirl.create(:person)
      @p3.communities << @c1
      @p3.ensure_authentication_token!
      
      request.env['Sharetribe-API-Token'] = @p3.authentication_token
      put :update, :id => @con1.id, 
                         :person_id => @p3.id,
                         :community_id => @c1.id,
                         :status => "accepted",
                         :format => :json
      response.status.should == 403
      resp = JSON.parse(response.body)
      resp[0].should == "The logged in user is not part of this conversation."
      
    end
  end


end