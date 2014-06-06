require 'spec_helper'

describe Admin::CommunitiesController do
  describe "#update_look_and_feel" do
    
    before(:each) do
      @community = FactoryGirl.create(:community)
      @request.host = "#{@community.domain}.lvh.me"
      sign_in_for_spec(create_admin_for(@community))
    end
    
    it "should allow changing custom_color1" do
      stanford_cardinal = "8C1515"
      put :update_look_and_feel, id: @community.id, community: { custom_color1: stanford_cardinal }
      @community.reload
      @community.custom_color1.should eql(stanford_cardinal)
    end
    
    it "should not allow changes to a different community" do
      different_community = FactoryGirl.create(:community)
      put :update_look_and_feel, id: different_community.id, community: { custom_color1: "8C1515" }
      different_community.reload
      different_community.custom_color1.should be_nil
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
end
