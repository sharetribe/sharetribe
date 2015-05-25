require 'spec_helper'

describe I18nHelper do

  describe "#facebook_locale_code" do

    let(:all_locales) {
      [
        {name: "English US", ident: "en", language: "en", region: "US"},
        {name: "Finnish", ident: "fi", language: "fi", region: "FI"},
        {name: "Spanish", ident: "es", language: "es", region: nil},
      ]
    }

    def expect_fb_locale(current_locale)
      expect(I18nHelper.facebook_locale_code(all_locales, current_locale))
    end

    context "success" do

      it "returns locale code in format that Facebook expects" do
        expect_fb_locale(:en).to eq("en_US")
        expect_fb_locale("fi").to eq("fi_FI")
      end

    end

    context "failure" do

      it "returns nil if locale can not be found" do
        expect_fb_locale(:sv).to eq(nil)
      end

      it "returns nil if locale does not have both language and region set" do
        expect_fb_locale(:es).to eq(nil)
      end
    end

  end

  describe "#select_locale" do

    let(:all_locales) {
      [
        {name: "English" , ident: "en" , language: "en" , region: "US" , fallback: nil },
        {name: "Spanish" , ident: "es" , language: "es" , region: "CL" , fallback: "es-ES" },
        {name: "Spanish" , ident: "es-ES" , language: "es" , region: "ES" , fallback: nil },
        {name: "French" , ident: "fr" , language: "fr" , region: "FR" , fallback: nil }
      ]
    }

    def expect_locale(opts)
      expect(I18nHelper.select_locale(opts))
    end

    it "uses user locale if available" do
      expect_locale(
        user_locale: "es",
        param_locale: "en",
        community_locales: ["fr", "en", "es"],
        community_default: "fr",
        all_locales: all_locales
      ).to eq("es")
    end

    it "otherwise uses user locale fallback if available" do
      expect_locale(
        user_locale: "es",
        param_locale: "en",
        community_locales: ["fr", "en", "es-ES"],
        community_default: "fr",
        all_locales: all_locales
      ).to eq("es-ES")
    end

    it "otherwise uses param locale if available" do
      expect_locale(
        user_locale: "en",
        param_locale: "es",
        community_locales: ["fr", "es"],
        community_default: "fr",
        all_locales: all_locales
      ).to eq("es")
    end

    it "otherwise uses param locale fallback if available" do
      expect_locale(
        user_locale: "en",
        param_locale: "es",
        community_locales: ["fr", "es-ES"],
        community_default: "fr",
        all_locales: all_locales
      ).to eq("es-ES")
    end

    it "otherwise uses community default" do
      expect_locale(
        user_locale: "en",
        param_locale: "fi",
        community_locales: ["fr", "es-ES"],
        community_default: "fr",
        all_locales: all_locales
      ).to eq("fr")
    end

  end
end
