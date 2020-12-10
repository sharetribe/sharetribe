require 'spec_helper'

describe Admin2::Advanced::CustomScriptsController, type: :controller do

  before(:each) do
    @community = FactoryGirl.create(:community)
    @request.host = "#{@community.ident}.lvh.me"
    @request.env[:current_marketplace] = @community
    @user = create_admin_for(@community)
    sign_in_for_spec(@user)
  end

  describe "#update_script" do
    let(:plan) do
      {
          expired: false,
          features: { custom_script: true }
      }
    end

    it "should not allow changing custom_head_script without plan" do
      script = "<script/>"
      patch :update_script, params: { id: @community.id, community: { custom_head_script: script } }
      @community.reload
      expect(@community.custom_head_script).to eql(nil)
    end

    it "should allow changing custom_head_script with plan" do
      @request.env[:current_plan] = plan
      script = "<script/>"
      patch :update_script, params: { id: @community.id, community: { custom_head_script: script } }
      @community.reload
      expect(@community.custom_head_script).to eql(script)
    end
  end

end
