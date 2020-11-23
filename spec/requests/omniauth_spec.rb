require 'spec_helper'

def header_authenticity_token(body)
  regex = /meta name="csrf-token" content="(?<token>.+)"/
  parts = response.body.match(regex)
  parts['token'] if parts
end

describe "omniauth csrf protection", type: :request do
  let!(:domain) { "market.custom.org" }

  before do
    @community = FactoryGirl.create(:community, :domain => domain, use_domain: true)
    @community.reload
    @allow_forgery_protection = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
  end

  after do
    ActionController::Base.allow_forgery_protection = @allow_forgery_protection
  end

  it 'does not allow GET requests' do
    get "https://#{domain}/people/auth/facebook"
    expect(response.status).to eq 404
  end

  it 'works with valid CSRF token' do
    get "https://#{domain}/login"
    token = header_authenticity_token(response.body)

    post "https://#{domain}/people/auth/facebook", params: {authenticity_token: token}
    expect(response.status).to eq 200
  end

  it 'refused with invalid CSRF token' do
    post "https://#{domain}/people/auth/facebook", params: {authenticity_token: "foobar"}
    expect(response.status).to eq 422
  end
end
