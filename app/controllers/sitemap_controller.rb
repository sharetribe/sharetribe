class SitemapController < ActionController::Metal

  include AbstractController::Rendering
  include ActionController::MimeResponds
  include ActionController::DataStreaming
  include ActionController::RackDelegation
  include ActionController::Rescue
  include ActionController::Head
  include ActionController::Redirecting

  def sitemap
    return unless can_show_sitemap?

    asset_host = APP_CONFIG.asset_host

    if asset_host.present?
      redirect_to ActionController::Base.helpers.asset_url("/sitemap/generate.xml")
    else
      render_site_map
    end
  end

  def generate
    return unless can_show_sitemap?

    render_site_map
  end

  private

  def community
    request.env[:current_marketplace]
  end

  def render_site_map
    sitemap = from_cache(community.id, max_sitemap_links) do
      adapter = SitemapGenerator::NeverWriteAdapter.new

      open_listings = find_open_listings(community.id)

      SitemapGenerator::Sitemap.create(
            default_host: request.base_url,
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
      .pluck(:id, :title, :updated_at)
      .map { |(id, title, updated_at)|
          {id: Listing.to_param(id, title), lastmod: updated_at}
      }
  end

  def from_cache(community_id, limit, &block)
    key = "sitemaps/#{community_id}/#{limit}"
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

  def can_show_sitemap?
    if community.deleted?
      head :not_found
      false
    elsif community.private?
      head :forbidden
      false
    else
      true
    end
  end

end
