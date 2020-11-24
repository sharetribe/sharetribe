class SitemapController < ActionController::Metal

  include AbstractController::Rendering
  include ActionController::MimeResponds
  include ActionController::DataStreaming
  include ActionController::Rescue
  include ActionController::Head
  include ActionController::Redirecting
  include ActionController::ConditionalGet

  # Ensure ActiveSupport::Notifications events are fired
  include ActionController::Instrumentation

  CACHE_TIME = APP_CONFIG[:sitemap_cache_time].to_i.seconds
  CACHE_HEADER = "X-Sitemap-Cache"

  def sitemap
    return if render_sitemap_disabled!

    com = community_from_request(request)
    reason = redirect_reason_from_request(request)

    return if render_not_found!(reason)
    return if render_private_community!(com)
    return if do_host_redirect!(com, reason)

    if APP_CONFIG.asset_host.present?
      redirect_to ActionController::Base.helpers.asset_path(
                    "/sitemap/#{request.host}/generate.xml.gz")
    else
      render_site_map(com)
    end
  end

  def generate
    return if render_sitemap_disabled!
    return if render_cdn_not_in_use!

    com = community_from_params(request)
    reason = redirect_reason(com)

    return if render_not_found!(reason)
    return if render_private_community!(com)

    render_site_map(com)
  end

  private

  def do_host_redirect!(community, reason)
    app_domain = URLUtils.strip_port_from_host(APP_CONFIG.domain)
    request_hash = MarketplaceRouter.request_hash(request)

    case reason
    when :use_domain
      redirect_to(
        MarketplaceRouter.domain_redirect_url(
          domain: community.domain,
          request: request_hash),
        status: :moved_permanently)

      true
    when :use_ident, :www_ident
      redirect_to(
        MarketplaceRouter.ident_redirect_url(
          ident: community.ident,
          app_domain: app_domain,
          request: request_hash),
        status: :moved_permanently)

      true
    end
  end

  def render_not_found!(reason)
    if [:deleted, :closed, :not_found, :no_marketplaces].include?(reason)
      head :not_found
      true
    end
  end

  def community(request)
    community_from_request(request) || community_from_params(request)
  end

  def community_from_request(request)
    request.env[:current_marketplace]
  end

  def community_from_params(request)
    host = request.params[:sitemap_host]

    if host.present?
      CurrentMarketplaceResolver.resolve_from_host(
        host, URLUtils.strip_port_from_host(APP_CONFIG.domain))
    end
  end

  def redirect_reason_from_request(request)
    request.env[:redirect_reason]
  end

  # This code is mostly copy-pasted from the MarketplaceLookup middleware
  #
  # This is the only controller action where we use params to identify the
  # community, thus we don't get the community by the middleware.
  #
  def redirect_reason(marketplace)
    app_domain = URLUtils.strip_port_from_host(::APP_CONFIG.domain)

    plan =
      if marketplace
        PlanService::API::Api.plans.get_current(community_id: marketplace.id).data
      end

    no_marketplaces =
      if marketplace
        false
      else
        Community.count == 0
      end

    MarketplaceRouter.redirect_reason(
      community: ::MarketplaceRouter.community_hash(marketplace, plan),
      host: request.host,
      no_communities: no_marketplaces,
      app_domain: app_domain)
  end

  def render_site_map(community)
    cache_hit = true
    default_host = community.full_domain(with_protocol: true)

    sitemap = from_cache([community.id, max_sitemap_links, default_host]) do
      cache_hit = false
      adapter = SitemapGenerator::NeverWriteAdapter.new

      open_listings = find_open_listings(community.id)

      SitemapGenerator::Sitemap.create(
            default_host: default_host,
            verbose: false,
            adapter: adapter) do
        open_listings.each do |l|
          add listing_path(id: l[:id]), lastmod: l[:lastmod]
        end
      end

      compressed = ActiveSupport::Gzip.compress(adapter.data)

      {
        content: compressed,
        digest: Digest::MD5.hexdigest(compressed),
        last_modified: Time.now
      }
    end

    headers[CACHE_HEADER] = cache_hit ? "1" : "0"
    expires_in(CACHE_TIME, public: true)

    if stale?(etag: sitemap[:digest], last_modified: sitemap[:last_modified])
      send_data(sitemap[:content], filename: "sitemap.xml.gz")
    end
  end

  def find_open_listings(community_id)
    Listing
      .currently_open
      .where(community_id: community_id)
      .limit(max_sitemap_links)
      .order(sort_date: :desc)
      .pluck(:id, :title, :updated_at)
      .map { |(id, title, updated_at)|
          {id: Listing.to_param(id, title), lastmod: updated_at}
      }
  end

  def from_cache(keys, &block)
    key = "sitemaps/#{keys.join("-")}"
    Rails.cache.fetch(key, expires_in: CACHE_TIME, &block)
  end

  def max_sitemap_links
    configured_limit = APP_CONFIG.max_sitemap_links
    max_limit = SitemapGenerator::MAX_SITEMAP_LINKS

    if configured_limit.present?
      [configured_limit.to_i, max_limit].min
    else
      max_limit
    end
  end

  def render_private_community!(community)
    if community.private?
      head :forbidden
      true
    end
  end

  def render_sitemap_disabled!
    unless sitemap_enabled?
      head :not_found
      true
    end
  end

  def render_cdn_not_in_use!
    unless APP_CONFIG.asset_host.present?
      head :not_found
      true
    end
  end

  def sitemap_enabled?
    APP_CONFIG.enable_sitemap&.to_s == "true"
  end

  # Override basic instrumentation and provide additional info for
  # lograge to consume. These are pulled and logged in environment
  # configs.
  def append_info_to_payload(payload)
    super
    payload[:community_id] = community(request)&.id
    payload[:current_user_id] = nil

    ControllerLogging.append_request_info_to_payload!(request, payload)
  end
end
