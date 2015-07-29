require 'spec_helper'

describe MarketplaceRedirectUtils do

  def expect_redirect(opts)
    url_and_status = MarketplaceRedirectUtils.needs_redirect(opts) { |url, status| [url, status] }
    expect(url_and_status)
  end

  it "redirects to domain" do
    expect_redirect(
      host: "www.marketplace.com",
      protocol: "https",
      fullpath: "/listings",
      community_domain: "www.marketplace.com",
      domain_ready: true).to eq(nil)

    expect_redirect(
      host: "marketplace.sharetribe.com",
      protocol: "https://",
      domain_ready: false,
      fullpath: "/listings").to eq(nil)

    expect_redirect(
      host: "marketplace.sharetribe.com",
      protocol: "https://",
      fullpath: "/listings",
      domain_ready: true,
      community_domain: "www.marketplace.com").to eq(["https://www.marketplace.com/listings", :moved_permanently])

    expect_redirect(
      host: "marketplace.sharetribe.com",
      protocol: "https://",
      fullpath: "/listings",
      domain_ready: false,
      community_domain: "www.marketplace.com").to eq(nil)
  end

end
