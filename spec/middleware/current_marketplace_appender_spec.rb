require 'spec_helper'

describe CurrentMarketplaceAppender do
  let(:app) { ->(env) {['200', {'Content-Type' => 'text/plain'}, [env.to_json]]} }
  let(:request) { Rack::MockRequest.new(CurrentMarketplaceAppender.new(app))}

  context 'appends the correct domain to env' do
    it 'gets the right community by subdomain' do
      c1 = FactoryGirl.create(:community, :ident => 'test23')
      c2 = FactoryGirl.create(:community, :domain => 'test23.custom.org')
      r = request.get 'https://test23.lvh.me', {'HTTP_HOST' => 'test23.lvh.me'}
      expect(JSON.parse(r.body)["current_marketplace"]["id"]).to eq(c1.id)
    end

    it 'gets the right community by full domain even when matching subdomain exists' do
      c1 = FactoryGirl.create(:community, :ident => 'market')
      c2 = FactoryGirl.create(:community, :domain => 'market.custom.org')
      r = request.get 'https://market.custom.org', {'HTTP_HOST' => 'market.custom.org'}
      expect(JSON.parse(r.body)["current_marketplace"]["id"]).to eq(c2.id)
    end
  end
end
