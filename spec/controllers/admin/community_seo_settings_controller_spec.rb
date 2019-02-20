require 'spec_helper'

describe Admin::CommunitySeoSettingsController, type: :controller do

  before(:each) do
    @community = FactoryGirl.create(:community)
    @request.host = "#{@community.ident}.lvh.me"
    @request.env[:current_marketplace] = @community
    @user = create_admin_for(@community)
    @user.update(is_admin: true)
    sign_in_for_spec(@user)
  end

  describe "#update" do
    it "updates meta description and title" do
      customization = @community.community_customizations.first
      put :update, params: {community: {community_customizations_attributes: {id: customization.id, meta_title: "Modified EN title", meta_description: "Modified EN description"}}}
      customization.reload
      expect(customization.meta_title).to eq("Modified EN title")
      expect(customization.meta_description).to eq("Modified EN description")
    end
  end
end

