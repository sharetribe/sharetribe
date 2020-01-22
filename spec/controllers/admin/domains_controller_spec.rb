require 'spec_helper'

describe Admin::DomainsController, type: :controller do
  let(:community) { FactoryGirl.create(:community) }
  let(:community_with_domain) { FactoryGirl.create(:community, domain: 'bonnie.com', use_domain: true) }
  let(:plan) do
    {
      expired: false,
      features: {
        whitelabel: false,
        admin_email: false,
        footer: false
      }
    }
  end
  let(:pro_plan) do
    {
      expired: false,
      features: {
        whitelabel: true,
        admin_email: false,
        footer: false
      }
    }
  end

  describe '#show community without domain' do
    before(:each) do
      @request.host = "#{community.ident}.lvh.me"
      @request.env[:current_marketplace] = community
      @request.env[:current_plan] = plan
      user = create_admin_for(community)
      sign_in_for_spec(user)
    end

    it 'works' do
      get :show
      presenter = assigns(:presenter)
      expect(presenter.domain_disabled?).to eq true
      expect(presenter.domain_possible?).to eq false
      expect(presenter.domain_used?).to eq false
      expect(presenter.domain_address).to eq "https://#{community.ident}.sharetribe.com"
    end
  end

  describe '#show community without domain with pro plan' do
    before(:each) do
      @request.host = "#{community.ident}.lvh.me"
      @request.env[:current_marketplace] = community
      @request.env[:current_plan] = pro_plan
      user = create_admin_for(community)
      sign_in_for_spec(user)
    end

    it 'works' do
      get :show
      presenter = assigns(:presenter)
      expect(presenter.domain_disabled?).to eq false
      expect(presenter.domain_possible?).to eq true
      expect(presenter.domain_used?).to eq false
      expect(presenter.domain_address).to eq "https://#{community.ident}.sharetribe.com"
    end
  end

  describe '#show community with domain with pro plan' do
    before(:each) do
      @request.host = community_with_domain.domain
      @request.env[:current_marketplace] = community_with_domain
      @request.env[:current_plan] = pro_plan
      user = create_admin_for(community_with_domain)
      sign_in_for_spec(user)
    end

    it 'works' do
      get :show
      presenter = assigns(:presenter)
      expect(presenter.domain_disabled?).to eq false
      expect(presenter.domain_possible?).to eq false
      expect(presenter.domain_used?).to eq true
      expect(presenter.domain_address).to eq "https://#{community_with_domain.domain}"
    end
  end

  describe '#update community without domain' do
    before(:each) do
      @request.host = "#{community.ident}.lvh.me"
      @request.env[:current_marketplace] = community
      @request.env[:current_plan] = plan
      user = create_admin_for(community)
      sign_in_for_spec(user)
    end

    it 'works' do
      expect(
        patch(:update, params: { community: { ident: 'rosemary' } })
      ).to redirect_to %r((http|https)://rosemary.lvh.me:9887)
    end
  end
end
