require 'spec_helper'

describe Admin::SettingsController, type: :controller do
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

  describe "#update" do
    it "works" do
      params = {
        join_with_invite_only: true,
        users_can_invite_new_users: true,
        private: true,
        require_verification_to_post_listings: true,
        show_category_in_listing_list: true,
        show_listing_publishing_date: true,
        listing_comments_in_use: true,
        automatic_confirmation_after_days: 15,
        automatic_newsletters: true,
        default_min_days_between_community_updates: 10,
        email_admins_about_new_members: true,
        pre_approved_listings: true
      }

      expect(community.join_with_invite_only).to eq false
      expect(community.users_can_invite_new_users).to eq false
      expect(community.private).to eq false
      expect(community.require_verification_to_post_listings).to eq false
      expect(community.show_category_in_listing_list).to eq false
      expect(community.show_listing_publishing_date).to eq false
      expect(community.listing_comments_in_use).to eq false
      expect(community.automatic_confirmation_after_days).to eq 14
      expect(community.automatic_newsletters).to eq false
      expect(community.default_min_days_between_community_updates).to eq 5
      expect(community.email_admins_about_new_members).to eq false
      expect(community.pre_approved_listings).to eq false

      put :update, params: {community: params}
      community.reload

      expect(community.join_with_invite_only).to eq true
      expect(community.users_can_invite_new_users).to eq true
      expect(community.private).to eq true
      expect(community.require_verification_to_post_listings).to eq true
      expect(community.show_category_in_listing_list).to eq true
      expect(community.show_listing_publishing_date).to eq true
      expect(community.listing_comments_in_use).to eq true
      expect(community.automatic_confirmation_after_days).to eq 15
      expect(community.automatic_newsletters).to eq true
      expect(community.default_min_days_between_community_updates).to eq 10
      expect(community.email_admins_about_new_members).to eq true
      paypal_settings = PaymentSettings.paypal.find_by(community_id: community.id)
      expect(paypal_settings.confirmation_after_days).to eq 15
      stripe_settings = PaymentSettings.stripe.find_by(community_id: community.id)
      expect(stripe_settings.confirmation_after_days).to eq 15
      expect(community.pre_approved_listings).to eq true
    end

  end
end
