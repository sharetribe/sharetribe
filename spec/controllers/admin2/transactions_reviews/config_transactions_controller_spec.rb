require 'spec_helper'

describe Admin2::TransactionsReviews::ConfigTransactionsController, type: :controller do
  let(:community) do
    FactoryGirl.create(:community,
                       automatic_confirmation_after_days: 1,
                       transaction_agreement_in_use: false)
  end

  let(:community_customization) do
    FactoryGirl.create(:community_customization,
                       community: community,
                       transaction_agreement_label: nil,
                       transaction_agreement_content: nil)
  end

  before(:each) do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    user = create_admin_for(community)
    sign_in_for_spec(user)
  end

  describe "#update_config" do
    it "works" do
      params = {
        automatic_confirmation_after_days: 22,
        transaction_agreement_in_use: true,
        community_customizations_attributes: { transaction_agreement_label: 'label',
                                               transaction_agreement_content: 'content',
                                               id: community_customization.id }
      }

      expect(community.automatic_confirmation_after_days).to eq 1
      expect(community.transaction_agreement_in_use).to eq false

      expect(community_customization.transaction_agreement_label).to eq nil
      expect(community_customization.transaction_agreement_content).to eq nil

      put :update_config, params: { community: params }
      community.reload
      community_customization.reload

      expect(community.automatic_confirmation_after_days).to eq 22
      expect(community.transaction_agreement_in_use).to eq true
      expect(community_customization.transaction_agreement_label).to eq 'label'
      expect(community_customization.transaction_agreement_content).to eq 'content'
    end
  end
end
