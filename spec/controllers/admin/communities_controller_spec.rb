require 'spec_helper'

describe Admin::CommunitiesController do
  
  before(:each) do
    @community = FactoryGirl.create(:community)
    @request.host = "#{@community.domain}.lvh.me"
    sign_in_for_spec(create_admin_for(@community))
  end

  describe "#update_settings" do
    it "should not allow changes to a different community" do
      attempt_to_update_different_community(:update_settings, private: true)
    end
  end
  
  describe "#update_look_and_feel" do        
    it "should allow changing custom_color1" do
      stanford_cardinal = "8C1515"
      put :update_look_and_feel, id: @community.id, community: { custom_color1: stanford_cardinal }
      @community.reload
      @community.custom_color1.should eql(stanford_cardinal)
    end
    
    it "should not allow changes to a different community" do
      attempt_to_update_different_community(:update_look_and_feel, custom_color1: "8C1515")
    end
    
    it "should not allow changing the plan level" do
      expect { 
        put :update_look_and_feel, id: @community.id, community: { plan_level: "7" }
      }.to raise_error ActionController::UnpermittedParameters 
    end
    
    context "when custom head scripts are allowed" do
      
      before { Community.any_instance.stub(:custom_head_script_in_use?).and_return(true) }
      
      it "should allow changing custom_head_script" do
        script = "<script/>"
        put :update_look_and_feel, id: @community.id, community: { custom_head_script: script }
        @community.reload
        @community.custom_head_script.should eql(script)
      end
    end
    
    context "when custom head scripts are not allowed" do
      
      before { Community.any_instance.stub(:custom_head_script_in_use?).and_return(false) }
      
      it "should allow changing custom_head_script" do
        expect {
          put :update_look_and_feel, id: @community.id, community: { custom_head_script: "foo" }
        }.to raise_error ActionController::UnpermittedParameters
      end
    end
  end
  
  def attempt_to_update_different_community(action, params)
    different_community = FactoryGirl.create(:community)
    put action, id: different_community.id, community: params
    different_community.reload
    params.each { |key, value| different_community.send(key).should_not eql(value) }
  end
end
