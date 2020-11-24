require 'spec_helper'

describe Admin2::Design::TopbarController, type: :controller do

  before(:each) do
    @community = FactoryGirl.create(:community)
    @request.host = "#{@community.ident}.lvh.me"
    @request.env[:current_marketplace] = @community
    @user = create_admin_for(@community)
    @user.update(is_admin: true)
    sign_in_for_spec(@user)
  end

  describe "#update_topbar" do
    before do
      allow(TranslationService::API::Api.translations).to receive(:create)
        .with(anything).and_return(Result::Success.new("success"))
    end

    it "should update Post new listing button text" do
      text_fi = "Modified fi"
      text_en = "Modified en"
      translations_group = [{
        translation_key: "homepage.index.post_new_listing",
        translations: [{ locale: "en", translation: text_en }, { locale: "fi", translation: text_fi }]
      }]

      RequestStore.store[:clp_enabled] = false
      expect(TranslationService::API::Api.translations).to receive(:create)
        .with(@community.id, translations_group)
      put :update_topbar, params: { id: @community.id, post_new_listing_button: {fi: text_fi, en: text_en}, community: { configuration_attributes: { display_about_menu: 1 }}}
    end

    it "should not update Post new listing button text with an invalid translation param" do
      text_fi = ""
      text_en = "Modified en"

      RequestStore.store[:clp_enabled] = false
      expect(TranslationService::API::Api.translations).to_not receive(:create).with(anything)
      patch :update_topbar, params: {post_new_listing_button: {fi: text_fi, en: text_en}, community: { configuration_attributes: { display_about_menu: 1 }}}
    end
  end

  describe "update default menu links" do
    it "should update default menu link settings" do
      text_fi = "Modified fi"
      text_en = "Modified en"
      RequestStore.store[:feature_flags] = nil

      menu_config = { configuration_attributes: {limit_priority_links: "-1", display_about_menu: "1", display_contact_menu: "1", display_invite_menu: "1"} }
      patch :update_topbar, params: { id: @community.id, post_new_listing_button: {fi: text_fi, en: text_en}, community: menu_config, enable_feature: "topbar_v1"}
      @community.reload
      expect(@community.configuration.display_about_menu).to eq true
      expect(@community.configuration.display_contact_menu).to eq true
      expect(@community.configuration.display_invite_menu).to eq true

      default_links = [
        {:link=>"/", :title=>"Home", :priority=>-1},
        {:link=>"/infos/about", :title=>"About", :priority=>0},
        {:link=>"/user_feedbacks/new", :title=>"Contact us", :priority=>1},
        {:link=>"/invitations/new", :title=>"Invite new members", :priority=>2}
      ]
      links = TopbarHelper.links(community: @community, user: @user, locale_param: nil, host_with_port: "http://#{@community.ident}.lvh.me")
      expect(links).to eq(default_links)

      menu_config = { configuration_attributes: {limit_priority_links: "-1", display_about_menu: "0", display_contact_menu: "0", display_invite_menu: "0"}}
      patch :update_topbar, params: { id: @community.id, post_new_listing_button: {fi: text_fi, en: text_en}, community: menu_config, enable_feature: "topbar_v1"}
      @community.reload
      expect(@community.configuration.display_about_menu).to eq false
      expect(@community.configuration.display_contact_menu).to eq false
      expect(@community.configuration.display_invite_menu).to eq false

      links = TopbarHelper.links(community: @community, user: @user, locale_param: nil, host_with_port: "http://#{@community.ident}.lvh.me")
      expect(links).to eq [{:link=>"/", :title=>"Home", :priority=>-1}]
    end
  end

  describe "update logo" do
    it "should update logo link" do
      text_fi = "Modified fi"
      text_en = "Modified en"

      patch :update_topbar, params: { id: @community.id, post_new_listing_button: {fi: text_fi, en: text_en}, community: {logo_link: "http://example.com", configuration_attributes: {limit_priority_links: "-1"} } }
      @community.reload
      expect(@community.logo_link).to eq "http://example.com"
    end
  end
end
