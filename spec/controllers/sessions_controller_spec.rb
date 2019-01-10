require 'spec_helper'

describe SessionsController, "POST create", type: :controller do

  before(:each) do
    community1 = FactoryGirl.create(:community,
                                    consent: "test_consent0.1",
                                    settings: {"locales" => ["en", "fi"]},
                                    real_name_required: true)

    person1 = FactoryGirl.create(:person,
                                 username: "testpersonusername",
                                 is_admin: 0, "locale" => "en",
                                 encrypted_password: "$2a$10$WQHcobA3hrTdSDh1jfiMquuSZpM3rXlcMU71bhE1lejzBa3zN7yY2",
                                 given_name: "Kassi",
                                 family_name: "Testperson1",
                                 phone_number: "0000-123456",
                                 created_at: "2012-05-04 18:17:04",
                                 community_id: community1.id)

    FactoryGirl.create(:community_membership,
                        person: person1,
                        community: community1,
                        admin: 1,
                        consent: "test_consent0.1",
                        last_page_load_date: DateTime.now,
                        status: "accepted" )

    @request.host = "#{community1.ident}.lvh.me"
    @request.env[:current_marketplace] = community1
  end

  it "redirects back to original community's domain" do
    post :create, params: {:person  => {:login => "testpersonusername", :password => "testi"}}
    expect(response).to redirect_to "http://#{@request.host}/"
  end
end

require 'spec_helper'

describe SessionsController, type: :controller do
  let(:community) { FactoryGirl.create(:community) }
  let(:person_global_admin_with_facebook_id) do
    FactoryGirl.create(:person, is_admin: true, facebook_id: '123')
  end
  let(:person_global_admin_with_facebook_email) do
    person = FactoryGirl.create(:person, is_admin: true)
    person.emails << FactoryGirl.create(:email, address: 'global_admin@example.com')
    person
  end
  let(:person_with_facebook_id) do
    FactoryGirl.create(:person, member_of: community, facebook_id: '345')
  end
  let(:person_with_facebook_email) do
    person = FactoryGirl.create(:person, member_of: community)
    person.emails << FactoryGirl.create(:email, address: 'alejandra@example.com')
    person
  end

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:person]
  end

  describe "#facebook" do
    before(:each) do
      @request.host = "#{community.ident}.lvh.me"
      @request.env[:current_marketplace] = community
    end

    it 'creates session data if FB user login first time' do
      oauth_mock('facebook')
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:facebook]
      post :facebook, params: { provider: 'facebook' }
      session_data = assigns(:service_session_data)
      expect(session_data).to eq({"provider"=>"facebook", "email"=>"markus@example.com", "given_name"=>"Markus", "family_name"=>"Sugarberg", "username"=>"markus.sharer-123", "id"=>"597013691"})
      expect(subject).to redirect_to action: :create_facebook_based, controller: :people
    end

    it 'sign in if FB uid fits for global admin' do
      person_global_admin_with_facebook_id
      oauth_mock('facebook', {extra: {raw_info: {id: '123'}}})
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:facebook]
      post :facebook, params: { provider: 'facebook' }
      expect(warden.authenticated?(:person)).to eq true
      expect(subject.current_person).to eq person_global_admin_with_facebook_id
    end

    it 'sign in if FB email fits for global admin' do
      person_global_admin_with_facebook_email
      oauth_mock('facebook', {extra: {raw_info: {email: 'global_admin@example.com'}}})
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:facebook]
      post :facebook, params: { provider: 'facebook' }
      expect(warden.authenticated?(:person)).to eq true
      expect(subject.current_person).to eq person_global_admin_with_facebook_email
    end

    it 'sign in if FB uid fits for person' do
      person_with_facebook_id
      oauth_mock('facebook', {extra: {raw_info: {id: '345'}}})
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:facebook]
      post :facebook, params: { provider: 'facebook' }
      expect(warden.authenticated?(:person)).to eq true
      expect(subject.current_person).to eq person_with_facebook_id
    end

    it 'sign in if FB email fits for person' do
      person_with_facebook_email
      oauth_mock('facebook', {extra: {raw_info: {email: 'alejandra@example.com'}}})
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:facebook]
      post :facebook, params: { provider: 'facebook' }
      expect(warden.authenticated?(:person)).to eq true
      expect(subject.current_person).to eq person_with_facebook_email
    end
  end
end
