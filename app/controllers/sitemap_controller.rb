class SitemapController < ActionController::Metal

  include AbstractController::Rendering
  include ActionController::MimeResponds
  include ActionController::DataStreaming
  include ActionController::RackDelegation
  include ActionController::Rescue
  include ActionController::Head

  def sitemap
    render_site_map
  end

  def self.find_open_listings(community_id)
    Listing
      .currently_open
      .where(community_id: community_id)
      .limit(SitemapGenerator::MAX_SITEMAP_LINKS)
      .pluck(:id, :title, :updated_at)
      .map { |l|
          # this is from Listing.to_param: "#{id}-#{title.to_url}"
          {id: "#{l[0]}-#{l[1].to_url}", lastmod: l[2]}
      }
  end

  private

  def render_site_map
    community = request.env[:current_marketplace]
    if community.deleted?
      head :not_found
      return
    end
    if community.private?
      head :forbidden
      return
    end
    respond_to do |format|

      compressed_data = Rails.cache.fetch("sitemaps/#{community.id}", expires_in: 24.hours) do
        adapter = SitemapGenerator::NeverWriteAdapter.new

        community_id = community.id

        SitemapGenerator::Sitemap.create(
              :default_host => request.base_url,
              :verbose => false,
              :adapter => adapter) do
                SitemapController.find_open_listings(community_id).each do |l|
                  add listing_path(id: l[:id]), :lastmod => l[:updated_at]
                end
        end

        compressed_data = ActiveSupport::Gzip.compress(adapter.data)
        compressed_data
      end
      format.xml_gz { send_data compressed_data }
      format.html { send_data compressed_data }
    end
  end

end
