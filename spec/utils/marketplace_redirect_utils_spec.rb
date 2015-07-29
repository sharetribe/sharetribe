require 'spec_helper'

describe MarketplaceRedirectUtils do

  def expect_redirect(opts)
    url_and_status = MarketplaceRedirectUtils.needs_redirect(opts) { |url, status| [url, status] }
    expect(url_and_status)
  end

  describe "#needs_redirect" do

    it "does not redirect to full domain if the host is already the full domain" do
      expect_redirect(
        host: "www.marketplace.com",
        protocol: "https",
        fullpath: "/listings",
        port_string: "",
        community_domain: "www.marketplace.com",
        redirect_to_domain: true).to eq(nil)
    end

    it "does not redirect to full domain if full domain is not provided" do
      expect_redirect(
        host: "marketplace.sharetribe.com",
        protocol: "https://",
        port_string: "",
        fullpath: "/listings",
        redirect_to_domain: false).to eq(nil)
    end

    it "redirects to full domain, if marketplace is accessed with the subdomain (ident) and full domain is provided and redirect_to_domain is true" do
      expect_redirect(
        host: "marketplace.sharetribe.com",
        protocol: "https://",
        fullpath: "/listings",
        port_string: "",
        redirect_to_domain: true,
        community_domain: "www.marketplace.com").to eq(["https://www.marketplace.com/listings", :moved_permanently])
    end

    it "does not redirect if redirect_to_domain is false" do
      expect_redirect(
        host: "marketplace.sharetribe.com",
        protocol: "https://",
        fullpath: "/listings",
        port_string: "",
        redirect_to_domain: false,
        community_domain: "www.marketplace.com").to eq(nil)
    end

    it "includes port" do
      expect_redirect(
        host: "marketplace.sharetribe.com",
        protocol: "https://",
        fullpath: "/listings",
        port_string: ":3333",
        redirect_to_domain: true,
        community_domain: "www.marketplace.com").to eq(["https://www.marketplace.com:3333/listings", :moved_permanently])
    end
  end
end
