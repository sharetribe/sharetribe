class SitemapController < ActionController::Metal

  include AbstractController::Rendering
  include ActionController::MimeResponds
  include ActionController::DataStreaming
  include ActionController::RackDelegation
  include ActionController::Rescue
  include ActionController::Head
  include ActionController::Redirecting

  def sitemap
    community = request.env[:current_marketplace]

    return unless can_show_sitemap?(community)

    if APP_CONFIG.asset_host.present?
      redirect_to ActionController::Base.helpers.asset_url(
                    "/sitemap/generate.xml?sitemap_host=#{request.host}")
    else
      render_site_map(community)
    end
  end

  def generate
    community = CurrentMarketplaceResolver.resolve_from_host(
      params[:sitemap_host], URLUtils.strip_port_from_host(APP_CONFIG.domain))

    return unless can_show_sitemap?(community)

    render_site_map(community)
  end

  private

  def render_site_map(community)
    default_host = community.full_domain(with_protocol: true)

    sitemap = from_cache([community.id, max_sitemap_links, default_host]) do
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

      adapter.data
    end

    send_data(sitemap, filename: "sitemap.xml")
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
    Rails.cache.fetch(key, expires_in: 24.hours, &block)
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

  def can_show_sitemap?(community)
    if APP_CONFIG.enable_sitemap&.to_s != "true"
      render_not_found
      false
    elsif community.nil?
      render_not_found
      false
    elsif community.deleted?
      head :not_found
      false
    elsif community.private?
      head :forbidden
      false
    else
      true
    end
  end

  def render_not_found(msg = "Not found")
    redirect_to "/404"
  end
end
