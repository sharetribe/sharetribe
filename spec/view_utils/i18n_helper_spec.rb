require 'spec_helper'

describe I18nHelper do

  describe "#facebook_locale_code" do

    ALL_LOCALES = [
      ["English US", "en", "en", "US"],
      ["Finnish", "fi", "fi", "FI"],
      ["Spanish", "es", "es", nil],
    ]

    def expect_fb_locale(current_locale)
      expect(I18nHelper.facebook_locale_code(ALL_LOCALES, current_locale))
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
end
