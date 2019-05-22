require 'spec_helper'

describe Devise::PasswordsController, type: :controller do
  let(:community) { FactoryGirl.create(:community) }

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:person]
  end

  it 'hides referer' do
    community_host(community)
    get :edit, params: {reset_password_token: 'abc'}
    expect(assigns(:hide_referer)).to eq true
  end
end

describe ApplicationController, type: :controller do
  let(:community) { FactoryGirl.create(:community) }
  let(:person) { FactoryGirl.create(:person, community_id: community.id) }

  controller do
    def index; end
  end

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:person]
  end

  it 'hides referer if auth token used' do
    community_host(community)
    item = UserService::API::AuthTokens.create_login_token(person.id)
    get :index, params: {auth: item[:token]}
    expect(assigns(:hide_referer)).to eq true
  end
end

def community_host(community)
  @request.host = "#{community.ident}.lvh.me"
  @request.env[:current_marketplace] = community
end

