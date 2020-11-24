require 'spec_helper'

describe Admin::CommunitiesController, type: :controller do

  before(:each) do
    @community = FactoryGirl.create(:community)
    @request.host = "#{@community.ident}.lvh.me"
    @request.env[:current_marketplace] = @community
    @user = create_admin_for(@community)
    sign_in_for_spec(@user)
  end

  describe "#update_integrations" do
    it "should allow changing twitter_handle" do
      update_community_with(:update_social_media, twitter_handle: "sharetribe")
    end

    it "should not allow changes to a different community" do
      attempt_to_update_different_community_with(:update_social_media, twitter_handle: "sharetribe")
    end
  end

  describe "#update_look_and_feel" do
    it "should allow changing custom_color1" do
      update_community_with(:update_look_and_feel, custom_color1: "8C1515")
    end

    it "should not allow changes to a different community" do
      attempt_to_update_different_community_with(:update_look_and_feel, custom_color1: "8C1515")
    end

    it "should allow changing custom_head_script" do
      script = "<script/>"
      put :update_look_and_feel, params: { id: @community.id, community: { custom_head_script: script } }
      @community.reload
      expect(@community.custom_head_script).to eql(script)
    end

  end

  describe "#update_new_layout" do
    before do
      # mock NewLayoutViewUtils.enabled_features with params
      allow(NewLayoutViewUtils).to receive(:enabled_features)
        .with(foo: "true", bar: "true").and_return([:foo, :bar])
      allow(NewLayoutViewUtils).to receive(:resolve_disabled)
        .with([:foo, :bar]).and_return([:wat])

      # mock NewLayoutViewUtils.enabled_features with empty params
      allow(NewLayoutViewUtils).to receive(:enabled_features)
        .with({}).and_return([])
      allow(NewLayoutViewUtils).to receive(:resolve_disabled)
        .with([]).and_return([:foo, :bar, :wat])

      # mock feature flag service calls
      allow(FeatureFlagService::API::Api.features).to receive(:enable)
        .with(anything()).and_return(Result::Success.new("success"))
      allow(FeatureFlagService::API::Api.features).to receive(:disable)
        .with(anything()).and_return(Result::Success.new("success"))
    end

    it "should enable given features for a user" do
      expect(FeatureFlagService::API::Api.features)
        .to receive(:enable).with(community_id: @community.id, person_id: @user.id, features: [:foo, :bar])
      put :update_new_layout, params: { enabled_for_user: { foo: "true", bar: "true"  } }
    end

    it "should disable missing features for a user" do
      expect(FeatureFlagService::API::Api.features)
        .to receive(:disable).with(community_id: @community.id, person_id: @user.id, features: [:wat])
      put :update_new_layout, params: { enabled_for_user: { foo: "true", bar: "true"  } }
    end

    it "should enable given features for a community" do
      expect(FeatureFlagService::API::Api.features)
        .to receive(:enable).with(community_id: @community.id, features: [:foo, :bar])
      put :update_new_layout, params: { enabled_for_community: { foo: "true", bar: "true"  } }
    end

    it "should disable missing features for a community" do
      expect(FeatureFlagService::API::Api.features)
        .to receive(:disable).with(community_id: @community.id, features: [:wat])
      put :update_new_layout, params: { enabled_for_community: { foo: "true", bar: "true"  } }
    end

    it "should disable all features when nothind is passed" do
      expect(FeatureFlagService::API::Api.features)
        .to receive(:disable).with(community_id: @community.id, features: [:foo, :bar, :wat])
      expect(FeatureFlagService::API::Api.features)
        .to receive(:disable).with(community_id: @community.id, person_id: @user.id, features: [:foo, :bar, :wat])
      put :update_new_layout
    end
  end

  describe "#update_social_media"  do
    it 'works' do
      put :update_social_media, params: {
        id: @community.id,
        community: {
          twitter_handle: 'ABC',
          facebook_connect_enabled: true,
          facebook_connect_id: '123',
          facebook_connect_secret: '46a4591952bdc5c00cfba5a607885f8a',
          google_connect_enabled: true,
          google_connect_id: '345',
          google_connect_secret: 'FGH',
          linkedin_connect_enabled: true,
          linkedin_connect_id: '678',
          linkedin_connect_secret: 'IJK'
        }
      }
      @community.reload
      expect(@community.twitter_handle).to eql('ABC')
      expect(@community.facebook_connect_enabled).to eql(true)
      expect(@community.facebook_connect_id).to eql('123')
      expect(@community.facebook_connect_secret).to eql('46a4591952bdc5c00cfba5a607885f8a')
      expect(@community.google_connect_enabled).to eql(true)
      expect(@community.google_connect_id).to eql('345')
      expect(@community.google_connect_secret).to eql('FGH')
      expect(@community.linkedin_connect_enabled).to eql(true)
      expect(@community.linkedin_connect_id).to eql('678')
      expect(@community.linkedin_connect_secret).to eql('IJK')
    end

    it 'strips spaces from connect fields' do
      put :update_social_media, params: {
        id: @community.id,
        community: {
          twitter_handle: ' ABC ',
          facebook_connect_enabled: true,
          facebook_connect_id: '    123 ',
          facebook_connect_secret: '   46a4591952bdc5c00cfba5a607885f8a ',
          google_connect_enabled: true,
          google_connect_id: '  345  ',
          google_connect_secret: '  FGH ',
          linkedin_connect_enabled: true,
          linkedin_connect_id: '  678  ',
          linkedin_connect_secret: ' IJK  '
        }
      }
      @community.reload
      expect(@community.twitter_handle).to eql('ABC')
      expect(@community.facebook_connect_enabled).to eql(true)
      expect(@community.facebook_connect_id).to eql('123')
      expect(@community.facebook_connect_secret).to eql('46a4591952bdc5c00cfba5a607885f8a')
      expect(@community.google_connect_enabled).to eql(true)
      expect(@community.google_connect_id).to eql('345')
      expect(@community.google_connect_secret).to eql('FGH')
      expect(@community.linkedin_connect_enabled).to eql(true)
      expect(@community.linkedin_connect_id).to eql('678')
      expect(@community.linkedin_connect_secret).to eql('IJK')
    end

    it 'updates social media title, description' do
      community_customization = @community.community_customizations.first
      put :update_social_media, params: {
        id: @community.id,
        community: {
          community_customizations_attributes: {
            id: community_customization.id,
            social_media_title: 'Hard Pill to Swallow',
            social_media_description: 'I think I will buy the red car, or I will lease the blue one.'
          }
        }
      }
      community_customization.reload
      expect(community_customization.social_media_title).to eql('Hard Pill to Swallow')
      expect(community_customization.social_media_description).to eql('I think I will buy the red car, or I will lease the blue one.')
    end
  end

  def attempt_to_update_different_community_with(action, params)
    different_community = FactoryGirl.create(:community)
    put action, params: {id: different_community.id, community: params}
    different_community.reload
    params.each { |key, value| expect(different_community.send(key)).not_to eql(value) }
  end

  def update_community_with(action, params)
    put action, params: {id: @community.id, community: params}
    @community.reload
    params.each { |key, value| expect(@community.send(:[], key)).to eql(value) }
  end

end
