require 'spec_helper'

describe Api::TestimonialsController do
  before(:each) do
    @p1 = FactoryGirl.create(:person)
    @p2 = FactoryGirl.create(:person)
    @t1 = FactoryGirl.create(:testimonial, :author => @p2, :receiver => @p1, :grade => 0.5, :text => "well done")
    @t2 = FactoryGirl.create(:testimonial, :author => @p2, :receiver => @p1, :grade => 0.75, :text => "Nice job!")
    @t3 = FactoryGirl.create(:testimonial, :author => @p1, :receiver => @p2, :grade => 1.0, :text => "awesome!")
  end

  describe "index" do
    it "returns one person's testimonials" do
      get :index, :person_id => @p1.id, :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)

      resp["feedbacks"].count.should == 2
      resp["page"].should == 1
      resp["per_page"].should == 50
      resp["total_pages"].should == 1
      resp["feedbacks"][1]["grade"].should == 0.5
      resp["feedbacks"][0]["grade"].should == 0.75
      resp["feedbacks"][1]["text"].should == "well done"
      resp["feedbacks"][0]["text"].should == "Nice job!"
    end
  end
end