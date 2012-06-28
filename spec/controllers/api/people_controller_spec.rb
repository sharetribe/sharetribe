require 'spec_helper'

describe Api::PeopleController do
  describe "show" do
    
    before(:each) do
      @p1 = FactoryGirl.create(:person)
      @c1 = FactoryGirl.create(:community)
      @c2 = FactoryGirl.create(:community)
      @p1.communities << @c1
      @p1.communities << @c2
    end
    
    it "returns basic json of a person" do
      get :show, :id => @p1.id, :format => :json
      resp = JSON.parse(response.body)
      puts response.body
    end
  end
end