describe Admin::Communities::TopbarController, type: :controller do

  before(:each) do
    @community = FactoryGirl.create(:community)
    @request.host = "#{@community.ident}.lvh.me"
    @request.env[:current_marketplace] = @community
    @user = create_admin_for(@community)
    sign_in_for_spec(@user)
  end

  describe "#update" do
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
      put :update, params: { id: @community.id, post_new_listing_button: {fi: text_fi, en: text_en} }
    end

    it "should not update Post new listing button text with an invalid translation param" do
      text_fi = ""
      text_en = "Modified en"

      expect(TranslationService::API::Api.translations).to_not receive(:create).with(anything())
      patch :update, params: {post_new_listing_button: {fi: text_fi, en: text_en}}
    end
  end

end
