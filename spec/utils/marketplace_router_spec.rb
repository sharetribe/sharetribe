require 'active_support/core_ext/object'
require 'possibly' # Maybe

[
  "app/utils/entity_utils",
  "app/utils/hash_utils",
  "app/utils/url_utils",
  "app/utils/marketplace_router",
].each { |f| require_relative "../../#{f}" }

describe MarketplaceRouter do

  def expect_target(reason:, request: {}, community: {}, paths: {}, other: {}, configs: {})
    default_request = {
      host: "marketplace.sharetribe.com",
      protocol: "https://",
      fullpath: "/listings",
      port_string: "",
      headers: {}
    }
    default_community = {
      use_domain: true,
      deleted: false,
      closed: false,
      domain: "www.marketplace.com",
      ident: "marketplace",
    }
    default_paths = {
      community_not_found: {route_name: :not_found},
      new_community: {route_name: :new_community},
    }
    default_configs = {
      app_domain: "sharetribe.com"
    }

    target = MarketplaceRouter.redirect_target(
      reason: reason,
      request: default_request.merge(request),
      community: community.nil? ? nil : default_community.merge(community),
      paths: default_paths.merge(paths),
      configs: default_configs.merge(configs)
    )

    expect(target)
  end

  describe "#redirect_target" do

    it "redirects to full domain, if marketplace is accessed with the subdomain (ident) and full domain is provided and use_domain is true" do
      expect_target(
        reason: :use_domain,
        community: {
          use_domain: true,
          deleted: false,
          domain: "www.marketplace.com",
        }).to eq(reason: :use_domain, url: "https://www.marketplace.com/listings", status: :moved_permanently)
    end

    it "includes port" do
      expect_target(
        reason: :use_domain,
        request: {
          port_string: ":3333",
        },
        community: {
          domain: "www.marketplace.com",
          deleted: false,
          use_domain: true,
        }).to eq(reason: :use_domain, url: "https://www.marketplace.com:3333/listings", status: :moved_permanently)
    end

    it "redirects deleted marketplaces" do
      expect_target(
        reason: :deleted,
        community: {
          domain: "www.marketplace.com",
          deleted: true,
          use_domain: true,
        }).to eq(reason: :deleted, route_name: :not_found, status: :moved_permanently)
    end

    it "redirects closed marketplaces" do
      expect_target(
        reason: :closed,
        community: {
          domain: "www.marketplace.com",
          closed: true,
          use_domain: true,
        }).to eq(reason: :closed, route_name: :not_found, status: :moved_permanently)
    end

    it "adds utm_ parameters when redirecting deleted" do
      expect_target(
        reason: :deleted,
        community: {
          deleted: true,
        },
        request: {
          host: "www.marketplace.com"
        },
        paths: {
          community_not_found: {url: "https://redirect.site.com"},
        }).to eq(reason: :deleted,
                 url: "https://redirect.site.com?utm_source=www.marketplace.com&utm_medium=redirect&utm_campaign=dl-auto-redirect",
                 status: :moved_permanently)
    end

    it "adds utm_ parameters when redirecting closed" do
      expect_target(
        reason: :closed,
        community: {
          closed: true,
        },
        request: {
          host: "www.marketplace.com"
        },
        paths: {
          community_not_found: {url: "https://redirect.site.com"},
        }).to eq(reason: :closed,
                 url: "https://redirect.site.com?utm_source=www.marketplace.com&utm_medium=redirect&utm_campaign=qc-auto-redirect",
                 status: :moved_permanently)
    end

    it "redirects to community not found if community was not found and some communities do exist" do
      expect_target(
        reason: :not_found,
        community: nil).to eq(reason: :not_found, route_name: :not_found, status: :found)
    end

    it "adds utm_ parameters when redirecting no community found and other communties exist" do
      expect_target(
        reason: :not_found,
        community: nil,
        request: { host: "www.wrongmarketplace.com" },
        paths: { community_not_found: { url: "https://redirect.site.com"} }
      ).to eq(reason: :not_found,
              url: "https://redirect.site.com?utm_source=www.wrongmarketplace.com&utm_medium=redirect&utm_campaign=na-auto-redirect",
              status: :found)
    end

    it "redirects to new community page if community was not found and no communities exist" do
      expect_target(
        reason: :no_marketplaces,
        community: nil,
        other: {
          no_communities: true,
        }).to eq(reason: :no_marketplaces, route_name: :new_community, status: :found)
    end

    it "redirects to marketplace ident without www" do
      expect_target(
        reason: :www_ident,
        request: {
          host: "www.marketplace.sharetribe.com",
        },
        community: {
          ident: "marketplace",
          domain: nil,
        },
        configs: {
          app_domain: "sharetribe.com"
        }
      ).to eq(reason: :www_ident, url: "https://marketplace.sharetribe.com/listings", status: :moved_permanently)
    end

    it "redirects to marketplace domain if available" do
      expect_target(
        reason: :use_domain,
        request: {
          host: "www.marketplace.sharetribe.com",
        },
        community: {
          ident: "marketplace",
          domain: "www.marketplace.com",
          use_domain: true
        }
      ).to eq(reason: :use_domain, url: "https://www.marketplace.com/listings", status: :moved_permanently)
    end

    it "redirects back to ident if domain is not in use" do
      expect_target(
        reason: :use_ident,
        request: {
          host: "www.marketplace.com",
        },
        community: {
          ident: "marketplace",
          domain: "www.marketplace.com",
          use_domain: false
        }
      ).to eq(reason: :use_ident, url: "https://marketplace.sharetribe.com/listings", status: :moved_permanently)
    end
  end

  describe "#redirect_reason" do

    def expect_reason(opts = {})
      defaults = {
        community: {
          use_domain: true,
          deleted: false,
          closed: false,
          domain: "www.marketplace.com",
          ident: "marketplace",
        },
        host: "marketplace.sharetribe.com",
        no_communities: false,
        app_domain: "sharetribe.com",
      }

      reason = MarketplaceRouter.redirect_reason(defaults.deep_merge(opts))
      expect(reason)
    end

    it "does not redirect to full domain if the host is already the full domain" do
      expect_reason(
        host: "www.marketplace.com").to eq(nil)
    end

    it "does not redirect to full domain if full domain is not provided" do
      expect_reason(
        community: {
          deleted: false,
          use_domain: false,
        }).to eq(nil)
    end

    it "redirects to full domain, if marketplace is accessed with the subdomain (ident) and full domain is provided and use_domain is true" do
      expect_reason(
        community: {
          use_domain: true,
          deleted: false,
          domain: "www.marketplace.com",
        }).to eq(:use_domain)
    end

    it "does not redirect if use_domain is false" do
      expect_reason(
        community: {
          deleted: false,
          domain: "www.marketplace.com",
          use_domain: false,
        }).to eq(nil)
    end

    it "redirects deleted marketplaces" do
      expect_reason(
        community: {
          domain: "www.marketplace.com",
          deleted: true,
          use_domain: true,
        }).to eq(:deleted)
    end

    it "redirects closed marketplaces" do
      expect_reason(
        community: {
          domain: "www.marketplace.com",
          closed: true,
          use_domain: true,
        }).to eq(:closed)
    end

    it "redirects to community not found if community was not found and some communities do exist" do
      expect_reason(community: nil).to eq(:not_found)
    end

    it "redirects to new community page if community was not found and no communities exist" do
      expect_reason(community: nil, no_communities: true).to eq(:no_marketplaces)
    end

    it "redirects to marketplace ident without www" do
      expect_reason(
        host: "www.marketplace.sharetribe.com",
        community: {
          ident: "marketplace",
          domain: nil,
        },
        app_domain: "sharetribe.com").to eq(:www_ident)
    end

    it "redirects to marketplace domain if available" do
      expect_reason(
        community: {
          ident: "marketplace",
          domain: "www.marketplace.com",
          use_domain: true
        },
        host: "www.marketplace.sharetribe.com").to eq(:use_domain)
    end

    it "redirects back to ident if domain is not in use" do
      expect_reason(
        host: "www.marketplace.com",
        community: {
          ident: "marketplace",
          domain: "www.marketplace.com",
          use_domain: false
        }).to eq(:use_ident)
    end
  end
end
