require 'spec_helper'

describe OmniauthController, type: :controller do
  let(:community) { FactoryGirl.create(:community) }

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:person]
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
  end

  describe "#facebook" do
    it 'creates and sign-in person if Facebook user login first time' do
      oauth_mock('facebook')
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:facebook]
      post :facebook
      expect(warden.authenticated?(:person)).to eq true
      new_person = assigns(:new_person)
      expect(new_person.username).to eq 'markusdotsharer123'
      expect(new_person.given_name).to eq 'Markus'
      expect(new_person.family_name).to eq 'Sugarberg'
      expect(new_person.display_name).to eq nil
      expect(new_person.facebook_id).to eq '597013691'
      expect(new_person.has_email?("markus@example.com")).to eq true
      expect(subject).to redirect_to pending_consent_path
    end
  end

  describe "#google_oauth2" do
    it 'creates and sign-in person if Google user login first time' do
      oauth_mock('google_oauth2')
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:google_oauth2]
      post :google_oauth2
      expect(warden.authenticated?(:person)).to eq true
      new_person = assigns(:new_person)
      expect(new_person.username).to eq 'johnd'
      expect(new_person.given_name).to eq 'John'
      expect(new_person.family_name).to eq 'Due'
      expect(new_person.display_name).to eq nil
      expect(new_person.google_oauth2_id).to eq '123456789012345678901'
      expect(new_person.has_email?("john@ithouse.lv")).to eq true
      expect(subject).to redirect_to pending_consent_path
    end
  end

  describe "#linkedin" do
    it 'creates and sign-in person if LinkedIn user login first time' do
      oauth_mock('linkedin')
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:linkedin]
      post :linkedin
      expect(warden.authenticated?(:person)).to eq true
      new_person = assigns(:new_person)
      expect(new_person.username).to eq 'tonyt'
      expect(new_person.given_name).to eq 'Tony'
      expect(new_person.family_name).to eq 'Testmen'
      expect(new_person.display_name).to eq nil
      expect(new_person.linkedin_id).to eq '50k-SSSS99'
      expect(new_person.has_email?("devel@example.com")).to eq true
      expect(subject).to redirect_to pending_consent_path
    end
  end

  shared_examples_for 'multi-provider authentication' do
    it "sign in if provider uid fits for global admin" do
      person_global_admin_with_provider_id
      oauth_mock(provider, {uid: '123'})
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[provider.to_sym]
      post provider.to_sym, params: { provider: provider }
      expect(warden.authenticated?(:person)).to eq true
      expect(subject.current_person).to eq person_global_admin_with_provider_id
    end

    it 'sign in if provider email fits for global admin' do
      person_global_admin_with_provider_email
      oauth_mock(provider, {info: {email: 'global_admin@example.com'}})
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[provider.to_sym]
      post provider.to_sym, params: { provider: provider }
      expect(warden.authenticated?(:person)).to eq true
      expect(subject.current_person).to eq person_global_admin_with_provider_email
    end

    it 'sign in if provider uid fits for person' do
      person_with_provider_id
      oauth_mock(provider, {uid: '345'})
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[provider.to_sym]
      post provider.to_sym, params: { provider: provider }
      expect(warden.authenticated?(:person)).to eq true
      expect(subject.current_person).to eq person_with_provider_id
    end

    it 'sign in if provider email fits for person' do
      person_with_provider_email
      oauth_mock(provider, {info: {email: 'alejandra@example.com'}})
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[provider.to_sym]
      post provider.to_sym, params: { provider: provider }
      expect(warden.authenticated?(:person)).to eq true
      expect(subject.current_person).to eq person_with_provider_email
    end
  end

  context 'Facebook' do
    let(:provider) { 'facebook' }
    let(:person_global_admin_with_provider_id) do
      FactoryGirl.create(:person, is_admin: true, facebook_id: '123')
    end
    let(:person_global_admin_with_provider_email) do
      person = FactoryGirl.create(:person, is_admin: true)
      person.emails << FactoryGirl.create(:email, address: 'global_admin@example.com')
      person
    end
    let(:person_with_provider_id) do
      FactoryGirl.create(:person, member_of: community, facebook_id: '345')
    end
    let(:person_with_provider_email) do
      person = FactoryGirl.create(:person, member_of: community)
      person.emails << FactoryGirl.create(:email, address: 'alejandra@example.com')
      person
    end
    it_behaves_like 'multi-provider authentication'
  end

  context 'Google' do
    let(:provider) { 'google_oauth2' }
    let(:person_global_admin_with_provider_id) do
      FactoryGirl.create(:person, is_admin: true, google_oauth2_id: '123')
    end
    let(:person_global_admin_with_provider_email) do
      person = FactoryGirl.create(:person, is_admin: true)
      person.emails << FactoryGirl.create(:email, address: 'global_admin@example.com')
      person
    end
    let(:person_with_provider_id) do
      FactoryGirl.create(:person, member_of: community, google_oauth2_id: '345')
    end
    let(:person_with_provider_email) do
      person = FactoryGirl.create(:person, member_of: community)
      person.emails << FactoryGirl.create(:email, address: 'alejandra@example.com')
      person
    end
    it_behaves_like 'multi-provider authentication'
  end

  context 'LinkedIn' do
    let(:provider) { 'linkedin' }
    let(:person_global_admin_with_provider_id) do
      FactoryGirl.create(:person, is_admin: true, linkedin_id: '123')
    end
    let(:person_global_admin_with_provider_email) do
      person = FactoryGirl.create(:person, is_admin: true)
      person.emails << FactoryGirl.create(:email, address: 'global_admin@example.com')
      person
    end
    let(:person_with_provider_id) do
      FactoryGirl.create(:person, member_of: community, linkedin_id: '345')
    end
    let(:person_with_provider_email) do
      person = FactoryGirl.create(:person, member_of: community)
      person.emails << FactoryGirl.create(:email, address: 'alejandra@example.com')
      person
    end
    it_behaves_like 'multi-provider authentication'
  end
end
