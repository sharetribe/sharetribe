require 'spec_helper'

describe "paypal_ipn ipn_hook", type: :request do
  before(:each) do
    @orig_ipn_domain = APP_CONFIG.paypal_ipn_domain
    APP_CONFIG.paypal_ipn_domain = "webhooks.example.com"
  end

  after(:each) do
    APP_CONFIG.paypal_ipn_domain = @orig_ipn_domain
  end

  it "handles non utf-8 encoding" do

    stub_request(:post, "https://www.sandbox.paypal.com/cgi-bin/webscr").to_return(status: 200, body: "VERIFIED", headers: {})

    params = "first_name=foo&last_name=fooá&charset=windows-1252".encode("windows-1252", "utf-8")
    post "http://webhooks.example.com/webhooks/paypal_ipn",
         params: params,
         headers: { "CONTENT_TYPE" => "application/x-www-form-urlencoded" }

    expect(controller.controller_name).to eq("paypal_ipn")
    expect(controller.action_name).to eq("ipn_hook")

    expect(response.status).to eq(200)
  end
end
