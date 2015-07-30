require 'spec_helper'

describe MarketplaceRedirectUtils do

  def expect_redirect(request: {}, community: {}, paths: {}, other: {}, configs: {})
    default_request = {
      host: "marketplace.sharetribe.com",
      protocol: "https://",
      fullpath: "/listings",
      port_string: "",
      headers: {}
    }
    default_community = {
      redirect_to_domain: true,
      community_deleted: false,
      community_domain: "www.marketplace.com",
      domain_verification_file: nil,
      community_ident: "marketplace",
    }
    default_paths = {
      community_not_found: {route_name: :not_found},
      new_community: {route_name: :new_community},
    }
    default_configs = {
      always_use_ssl: true,
      app_domain: "sharetribe.com"
    }
    default_other = {
      no_communities: false
    }

    result = MarketplaceRedirectUtils.needs_redirect(
      request: default_request.merge(request),
      community: community.nil? ? nil : default_community.merge(community),
      paths: default_paths.merge(paths),
      configs: default_configs.merge(configs),
      other: other
    ) { |x| x }

    expect(result)
  end

  describe "#needs_redirect" do

    it "does not redirect to full domain if the host is already the full domain" do
      expect_redirect(request: {
                        host: "www.marketplace.com",
                      }).to eq(nil)
    end

    it "does not redirect to full domain if full domain is not provided" do
      expect_redirect(community: {
                        community_deleted: false,
                        redirect_to_domain: false,
                      }).to eq(nil)
    end

    it "redirects to full domain, if marketplace is accessed with the subdomain (ident) and full domain is provided and redirect_to_domain is true" do
      expect_redirect(community: {
                        redirect_to_domain: true,
                        community_deleted: false,
                        community_domain: "www.marketplace.com",
                      }).to eq(url: "https://www.marketplace.com/listings", status: :moved_permanently)
    end

    it "does not redirect if redirect_to_domain is false" do
      expect_redirect(community: {
                        community_deleted: false,
                        community_domain: "www.marketplace.com",
                        redirect_to_domain: false,
                      }).to eq(nil)
    end

    it "includes port" do
      expect_redirect(request: {
                        port_string: ":3333",
                      },
                      community: {
                        community_domain: "www.marketplace.com",
                        community_deleted: false,
                        redirect_to_domain: true,
                      }).to eq(url: "https://www.marketplace.com:3333/listings", status: :moved_permanently)
    end

    it "redirects deleted marketplaces" do
      expect_redirect(community: {
                        community_domain: "www.marketplace.com",
                        community_deleted: true,
                        redirect_to_domain: true,
                      }).to eq(route_name: :not_found, status: :moved_permanently, protocol: "https")
    end

    it "redirects deleted marketplaces" do
      expect_redirect(community: {
                        community_domain: "www.marketplace.com",
                        community_deleted: true,
                        redirect_to_domain: true,
                      }).to eq(route_name: :not_found, status: :moved_permanently, protocol: "https")
    end

    it "redirects to community not found if community was not found and some communities do exist" do
      expect_redirect(community: nil).to eq(route_name: :not_found, status: :found, protocol: "https")
    end

    it "redirects to community not found if community was not found and some communities do exist" do
      expect_redirect(community: nil,
                      other: {
                        no_communities: true,
                      }).to eq(route_name: :new_community, status: :found, protocol: "https")
    end

    it "redirects to https if always_use_ssl configuration is set true" do
      expect_redirect(request: {
                        protocol: "http://",
                      },
                      community: {
                        community_domain: "www.marketplace.com",
                        community_deleted: false,
                        redirect_to_domain: true,
                      }).to eq(url: "https://www.marketplace.com/listings", status: :moved_permanently)
    end

    it "redirects to https even if there's no other reason to do redirect" do
      expect_redirect(request: {
                        protocol: "http://",
                      },
                      community: {
                        community_domain: nil,
                        community_deleted: false,
                        redirect_to_domain: false,
                      }).to eq(url: "https://marketplace.sharetribe.com/listings", status: :moved_permanently)
    end

    it "redirects to protocol in use if always_use_ssl configuration is set false" do
      expect_redirect(request: {
                        protocol: "http://",
                      },
                      community: {
                        community_domain: "www.marketplace.com",
                        community_deleted: false,
                        redirect_to_domain: true,
                      },
                      configs: {
                        always_use_ssl: false,
                      }).to eq(url: "http://www.marketplace.com/listings", status: :moved_permanently)
    end

    it "redirects with moved permanently if the protocol needs redirect even if it would otherwise used found status" do
      expect_redirect(community: nil,
                      request: {
                        protocol: "http://",
                      }).to eq(route_name: :not_found, status: :moved_permanently, protocol: "https")
    end

    it "doesn't redirect to https if the request comes from proxy, even if always_use_ssl is true" do
      expect_redirect(request: {
                        host: "www.marketplace.com",
                        protocol: "http://",
                        headers: {
                          "HTTP_VIA" => "random_proxy"
                        }
                      }).to eq({url: "https://www.marketplace.com/listings", status: :moved_permanently})

      expect_redirect(request: {
                        host: "www.marketplace.com",
                        protocol: "http://",
                        headers: {
                          "HTTP_VIA" => ["sharetribe_proxy"]
                        }
                      }).to eq(nil)
    end

    it "doesn't redirect robots.txt to https" do
      expect_redirect(request: {
                        host: "www.marketplace.com",
                        protocol: "http://",
                        fullpath: "/robots.txt",
                        }
                      ).to eq(nil)
    end

    it "doesn't redirect domain verification file" do
      expect_redirect(request: {
                        host: "www.marketplace.com",
                        protocol: "http://",
                        fullpath: "/1234567890ABCDEF.txt",
                      },
                      community: {
                        domain_verification_file: "no-match-domain-verification-file.txt"
                      }
                     ).to eq(:url=>"https://www.marketplace.com/1234567890ABCDEF.txt", :status=>:moved_permanently)

      expect_redirect(request: {
                        host: "www.marketplace.com",
                        protocol: "http://",
                        fullpath: "/1234567890ABCDEF.txt",
                      },
                      community: {
                        domain_verification_file: "1234567890ABCDEF.txt"
                      }
                      ).to eq(nil)
    end

    it "redirects to marketplace ident without www" do
      expect_redirect(request: {
                        host: "www.marketplace.sharetribe.com",
                      },
                      community: {
                        community_ident: "marketplace",
                        community_domain: nil,
                      },
                      configs: {
                        app_domain: "sharetribe.com"
                      }
                     ).to eq(:url=>"https://marketplace.sharetribe.com/listings", :status=>:moved_permanently)
    end

    it "redirects to marketplace domain if available" do
      expect_redirect(request: {
                        host: "www.marketplace.sharetribe.com",
                      },
                      community: {
                        community_ident: "marketplace",
                        community_domain: "www.marketplace.com",
                        redirect_to_domain: true
                      }
                     ).to eq(:url=>"https://www.marketplace.com/listings", :status=>:moved_permanently)
    end
  end
end
