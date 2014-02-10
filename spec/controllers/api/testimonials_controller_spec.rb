require 'spec_helper'

describe Api::TestimonialsController do
  render_views
  
  before(:each) do
    pending("API tests are pending")
    @p1 = FactoryGirl.create(:person)
    @p2 = FactoryGirl.create(:person)
    @c1 = FactoryGirl.create(:conversation)
    @pa1 = FactoryGirl.create(:participation, :person => @p1, :conversation => @c1)
    @pa2 = FactoryGirl.create(:participation, :person => @p2, :conversation => @c1)
    @t1 = FactoryGirl.create(:testimonial, :author => @p2, :receiver => @p1, :grade => 0.5, :text => "well done", :participation => @pa1)
    @t2 = FactoryGirl.create(:testimonial, :author => @p2, :receiver => @p1, :grade => 0.75, :text => "Nice job!", :participation => @pa1)
    @t3 = FactoryGirl.create(:testimonial, :author => @p1, :receiver => @p2, :grade => 1.0, :text => "awesome!", :participation => @pa2)
  end

  describe "index" do
    it "returns one person's testimonials" do
      get :index, :person_id => @p1.id, :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)
      #puts resp.to_yaml
      resp["feedbacks"].count.should == 2
      resp["page"].should == 1
      resp["per_page"].should == 50
      resp["total_pages"].should == 1
      resp["feedbacks"][1]["grade"].should == 0.5
      resp["feedbacks"][0]["grade"].should == 0.75
      resp["feedbacks"][1]["text"].should == "well done"
      resp["feedbacks"][0]["text"].should == "Nice job!"
      resp["feedbacks"][1]["conversation_id"].should == @c1.id
      resp["feedbacks"][0]["conversation_id"].should == @c1.id
      resp["feedbacks"][1]["author"]["id"].should == @p2.id
      resp["feedbacks"][0]["author"]["id"].should == @p2.id
    end
  end
end