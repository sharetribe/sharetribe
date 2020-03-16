require 'spec_helper'

describe Admin2::Advanced::DeleteMarketplacesController, type: :controller do
  let(:community) do
    community = FactoryGirl.create(:community,
                                   join_with_invite_only: false,
                                   users_can_invite_new_users: false,
                                   private: false,
                                   require_verification_to_post_listings: false,
                                   show_category_in_listing_list: false,
                                   show_listing_publishing_date: false,
                                   listing_comments_in_use: false,
                                   automatic_confirmation_after_days: 14,
                                   automatic_newsletters: false,
                                   default_min_days_between_community_updates: 5,
                                   email_admins_about_new_members: false,
                                   pre_approved_listings: false)
    FactoryGirl.create(:payment_settings,
                       community_id: community.id,
                       payment_gateway: 'paypal')
    FactoryGirl.create(:payment_settings,
                       community_id: community.id,
                       payment_gateway: 'stripe')
    community
  end

  before(:each) do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    user = create_admin_for(community)
    sign_in_for_spec(user)
  end

  describe "#destroy" do
    it 'works' do
      delete :destroy, params: {id: community.id, delete_confirmation: community.ident}
      expect(community.reload.deleted).to eq true
    end
  end
end

