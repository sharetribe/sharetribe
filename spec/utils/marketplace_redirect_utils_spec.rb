require 'spec_helper'

describe MarketplaceRedirectUtils do

  def expect_redirect(opts)
    result = MarketplaceRedirectUtils.needs_redirect(opts) { |x| x }
    expect(result)
  end

  describe "#needs_redirect" do

    it "does not redirect to full domain if the host is already the full domain" do
      expect_redirect(
        host: "www.marketplace.com",
        protocol: "https://",
        always_use_ssl: true,
        fullpath: "/listings",
        port_string: "",
        headers: {},
        is_ssl: true,
        community_domain: "www.marketplace.com",
        community_not_found_url: {route_name: :not_found},
        community_deleted: false,
        found_community: true,
        no_communities: false,
        new_community_path: {route_name: :new_community},
        redirect_to_domain: true).to eq(nil)
    end

    it "does not redirect to full domain if full domain is not provided" do
      expect_redirect(
        host: "marketplace.sharetribe.com",
        protocol: "https://",
        always_use_ssl: true,
        port_string: "",
        fullpath: "/listings",
        headers: {},
        is_ssl: true,
        community_not_found_url: {route_name: :not_found},
        community_deleted: false,
        found_community: true,
        no_communities: false,
        new_community_path: {route_name: :new_community},
        redirect_to_domain: false).to eq(nil)
    end

    it "redirects to full domain, if marketplace is accessed with the subdomain (ident) and full domain is provided and redirect_to_domain is true" do
      expect_redirect(
        host: "marketplace.sharetribe.com",
        protocol: "https://",
        fullpath: "/listings",
        always_use_ssl: true,
        port_string: "",
        headers: {},
        is_ssl: true,
        redirect_to_domain: true,
        community_not_found_url: {route_name: :not_found},
        community_deleted: false,
        found_community: true,
        no_communities: false,
        new_community_path: {route_name: :new_community},
        community_domain: "www.marketplace.com").to eq(url: "https://www.marketplace.com/listings", status: :moved_permanently)
    end

    it "does not redirect if redirect_to_domain is false" do
      expect_redirect(
        host: "marketplace.sharetribe.com",
        protocol: "https://",
        always_use_ssl: true,
        fullpath: "/listings",
        port_string: "",
        headers: {},
        is_ssl: true,
        redirect_to_domain: false,
        community_not_found_url: {route_name: :not_found},
        community_deleted: false,
        found_community: true,
        no_communities: false,
        new_community_path: {route_name: :new_community},
        community_domain: "www.marketplace.com").to eq(nil)
    end

    it "includes port" do
      expect_redirect(
        host: "marketplace.sharetribe.com",
        protocol: "https://",
        fullpath: "/listings",
        always_use_ssl: true,
        port_string: ":3333",
        headers: {},
        is_ssl: true,
        redirect_to_domain: true,
        community_not_found_url: {route_name: :not_found},
        community_deleted: false,
        found_community: true,
        no_communities: false,
        new_community_path: {route_name: :new_community},
        community_domain: "www.marketplace.com").to eq(url: "https://www.marketplace.com:3333/listings", status: :moved_permanently)
    end

    it "redirects deleted marketplaces" do
      expect_redirect(
        host: "marketplace.sharetribe.com",
        protocol: "https://",
        always_use_ssl: true,
        fullpath: "/listings",
        port_string: "",
        headers: {},
        is_ssl: true,
        redirect_to_domain: true,
        community_not_found_url: {route_name: :not_found},
        community_deleted: true,
        found_community: true,
        no_communities: false,
        new_community_path: {route_name: :new_community},
        community_domain: "www.marketplace.com").to eq(route_name: :not_found, status: :moved_permanently, protocol: "https")
    end

    it "redirects deleted marketplaces" do
      expect_redirect(
        host: "marketplace.sharetribe.com",
        protocol: "https://",
        always_use_ssl: true,
        fullpath: "/listings",
        port_string: "",
        headers: {},
        is_ssl: true,
        redirect_to_domain: true,
        community_not_found_url: {route_name: :not_found},
        community_deleted: true,
        found_community: true,
        no_communities: false,
        new_community_path: {route_name: :new_community},
        community_domain: "www.marketplace.com").to eq(route_name: :not_found, status: :moved_permanently, protocol: "https")
    end

    it "redirects to community not found if community was not found and some communities do exist" do
      expect_redirect(
        host: "marketplace.sharetribe.com",
        protocol: "https://",
        always_use_ssl: true,
        fullpath: "/listings",
        port_string: "",
        headers: {},
        is_ssl: true,
        redirect_to_domain: nil,
        community_not_found_url: {route_name: :not_found},
        community_deleted: nil,
        no_communities: false,
        found_community: false,
        new_community_path: {route_name: :new_community},
        community_domain: nil).to eq(route_name: :not_found, status: :found, protocol: "https")
    end

    it "redirects to community not found if community was not found and some communities do exist" do
      expect_redirect(
        host: "marketplace.sharetribe.com",
        protocol: "https://",
        always_use_ssl: true,
        fullpath: "/listings",
        port_string: "",
        headers: {},
        is_ssl: true,
        redirect_to_domain: nil,
        community_not_found_url: {route_name: :not_found},
        community_deleted: nil,
        no_communities: true,
        found_community: false,
        new_community_path: {route_name: :new_community},
        community_domain: nil).to eq(route_name: :new_community, status: :found, protocol: "https")
    end

    it "redirects to https if always_use_ssl configuration is set true" do
      expect_redirect(
        host: "marketplace.sharetribe.com",
        headers: {},
        is_ssl: false,
        always_use_ssl: true,
        protocol: "http://",
        fullpath: "/listings",
        port_string: "",
        redirect_to_domain: true,
        community_not_found_url: {route_name: :not_found},
        community_deleted: false,
        no_communities: false,
        found_community: true,
        new_community_path: {route_name: :new_community},
        community_domain: "www.marketplace.com").to eq(url: "https://www.marketplace.com/listings", status: :moved_permanently)
    end

    it "redirects to https even if there's no other reason to do redirect" do
      expect_redirect(
        host: "marketplace.sharetribe.com",
        headers: {},
        is_ssl: false,
        always_use_ssl: true,
        protocol: "http://",
        fullpath: "/listings",
        port_string: "",
        redirect_to_domain: false,
        community_not_found_url: {route_name: :not_found},
        community_deleted: false,
        no_communities: false,
        found_community: true,
        new_community_path: {route_name: :new_community},
        community_domain: nil).to eq(url: "https://marketplace.sharetribe.com/listings", status: :moved_permanently)
    end

    it "redirects to protocol in use if always_use_ssl configuration is set false" do
      expect_redirect(
        host: "marketplace.sharetribe.com",
        headers: {},
        is_ssl: false,
        always_use_ssl: false,
        protocol: "http://",
        fullpath: "/listings",
        port_string: "",
        redirect_to_domain: true,
        community_not_found_url: {route_name: :not_found},
        community_deleted: false,
        no_communities: false,
        found_community: true,
        new_community_path: {route_name: :new_community},
        community_domain: "www.marketplace.com").to eq(url: "http://www.marketplace.com/listings", status: :moved_permanently)
    end

    it "redirects with moved permanently if the protocol needs redirect even if it would otherwise used found status" do
      expect_redirect(
        host: "marketplace.sharetribe.com",
        protocol: "http://",
        always_use_ssl: true,
        fullpath: "/listings",
        port_string: "",
        headers: {},
        is_ssl: true,
        redirect_to_domain: nil,
        community_not_found_url: {route_name: :not_found},
        community_deleted: nil,
        no_communities: false,
        found_community: false,
        new_community_path: {route_name: :new_community},
        community_domain: nil).to eq(route_name: :not_found, status: :moved_permanently, protocol: "https")
    end
  end
end
