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
      request_params = {
        community: {
          community_customizations_attributes: {
            id: customization.id,
            meta_title: "Modified EN title", meta_description: "Modified EN description",
            search_meta_title: "Modified EN search title", search_meta_description: "Modified EN search description",
            listing_meta_title: "Modified EN listing title", listing_meta_description: "Modified EN listing description",
            profile_meta_title: "Modified EN profile title", profile_meta_description: "Modified EN profile description",
            category_meta_title: "Modified EN category title", category_meta_description: "Modified EN category description"
          }
        }
      }
      put :update, params: request_params
      customization.reload
      request_params[:community][:community_customizations_attributes].each do |key, value|
        expect(customization[key]).to eq(value)
      end
    end
  end
end
