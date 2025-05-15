require 'spec_helper'

describe Admin2::Advanced::RecaptchaController, type: :controller do

  before(:each) do
    @community = FactoryBot.create(:community)
    @request.host = "#{@community.ident}.lvh.me"
    @request.env[:current_marketplace] = @community
    @user = create_admin_for(@community)
    sign_in_for_spec(@user)
  end

  describe "#update_recaptcha" do
    it "should allow changing recaptcha" do
      key = "6Lf9Ig8aAAAAANSxRG-UcXUZcoLetgyeGA1MWc13"
      secret = "6Lf9Ig8aAAAAANSxRG-UcXUZcoLetgyeGA1MWc14"
      patch :update_recaptcha, params: { community: { recaptcha_site_key: key, recaptcha_secret_key: secret } }
      @community.reload
      expect(@community.recaptcha_site_key).to eql(key)
      expect(@community.recaptcha_secret_key).to eql(secret)
    end
  end
end
