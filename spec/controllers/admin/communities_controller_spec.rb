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

  describe "#update_settings" do
    it "should allow changing 'private'" do
      update_community_with(:update_settings, private: true)
    end

    it "should not allow changes to a different community" do
      attempt_to_update_different_community_with(:update_settings, private: true)
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

  describe "#update_topbar" do
    before do
      allow(TranslationService::API::Api.translations).to receive(:create)
        .with(anything()).and_return(Result::Success.new("success"))
    end

    it "should update Post new listing button text" do
      text_fi = "Modified fi"
      text_en = "Modified en"
      translations_group = [{
        translation_key: "homepage.index.post_new_listing",
        translations: [{ locale: "en", translation: text_en }, { locale: "fi", translation: text_fi } ]
      }]

      expect(TranslationService::API::Api.translations).to receive(:create)
        .with(@community.id, translations_group)
      put :update_topbar, params: { id: @community.id, post_new_listing_button: {fi: text_fi, en: text_en} }
    end

    it "should not update Post new listing button text with an invalid translation param" do
      text_fi = ""
      text_en = "Modified en"

      expect(TranslationService::API::Api.translations).to_not receive(:create).with(anything())
      patch :update_topbar, params: {post_new_listing_button: {fi: text_fi, en: text_en}}
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
