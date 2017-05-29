require 'spec_helper'

describe SettingsController, type: :controller do

  before(:each) do
    @community = FactoryGirl.create(:community)
    @request.host = "#{@community.ident}.lvh.me"
    @request.env[:current_marketplace] = @community
    @person = FactoryGirl.create(:person)

    FactoryGirl.create(:community_membership, :person => @person, :community => @community)
  end

  describe "#unsubscribe" do

    it "should unsubscribe the user from the email specified in parameters" do
      sign_in_for_spec(@person)
      @person.set_default_preferences
      expect(@person.min_days_between_community_updates).to eq(1)

      get :unsubscribe, params: {:email_type => "community_updates", :person_id => @person.username}
      puts response.body
      expect(response.status).to eq(200)

      @person = Person.find(@person.id) # fetch again to refresh
      expect(@person.min_days_between_community_updates).to eq(100000)
    end

    it "should unsubscribe with auth token" do
      t = AuthToken.create_unsubscribe_token(person_id: @person.id).token
      @person.set_default_preferences
      expect(@person.min_days_between_community_updates).to eq(1)

      get :unsubscribe, params: {:email_type => "community_updates", :person_id => @person.username, :auth => t}
      expect(response.status).to eq(200)

      @person = Person.find(@person.id) # fetch again to refresh
      expect(@person.min_days_between_community_updates).to eq(100000)
    end

    it "should not unsubscribe if no token provided" do
      @person.set_default_preferences
      expect(@person.min_days_between_community_updates).to eq(1)

      get :unsubscribe, params: {:email_type => "community_updates", :person_id => @person.username} 
      expect(response.status).to eq(401)
      expect(@person.min_days_between_community_updates).to eq(1)
    end
  end
end
