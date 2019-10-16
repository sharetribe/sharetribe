require 'csv'
class ExportListingsJob < Struct.new(:current_user_id, :community_id, :export_task_id)
  include DelayedAirbrakeNotification
  include ListingsHelper

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    community = Community.find(community_id)
    export_task = ExportTaskResult.find(export_task_id)
    export_task.update(status: 'started')

    csv_content = generate_csv_content(community)

    marketplace_name = community.use_domain ? community.domain : community.ident
    filename = "#{marketplace_name}-listings-#{Time.zone.today}-#{export_task.token}.csv"
    export_task.original_filename = filename
    export_task.original_extname = File.extname(filename).delete('.')
    export_task.update(status: 'finished', file: FakeFileIO.new(filename, csv_content))
  end

  def generate_csv_content(community)
    I18nHelper.initialize_community_backend!(community.id, community.locales)

    locale = community.default_locale

    # local cache for category names to avoid extra SQL
    categories_list = community.categories.map do |category|
      [
        category.id,
        {parent: category.parent_id, name: category.display_name(locale)}
      ]
    end
    categories_hash = Hash[categories_list]

    generate_csv_rows(community.listings.for_export, locale, categories_hash).join("")
  end

  def generate_csv_rows(listings, locale, categories)
    out = []
    # first line is column names
    out << %w{
      listing_id
      listing_title
      user_id
      created_at
      updated_at
      status
      category
      order_type
      price
      currency
      pricing_unit
      main_image_url
    }.to_csv(force_quotes: true)
    listings.each do |listing|
      out << [
        listing.id,
        listing.title,
        listing.author_id,
        listing.created_at && I18n.l(listing.created_at, format: '%Y-%m-%d %H:%M:%S'),
        listing.updated_at && I18n.l(listing.updated_at, format: '%Y-%m-%d %H:%M:%S'),
        status_title(listing, locale),
        category_title(listing.category_id, categories),
        I18n.t(listing.shape_name_tr_key, locale: locale),
        listing.price.present? && listing.price > 0 ? listing.price.to_s : 0,
        listing.price.present? && listing.price > 0 ? listing.price.currency.to_s : "",
        price_quantity_per_unit(listing, locale),
        main_image_url(listing)
      ].to_csv(force_quotes: true)
    end
    out
  end

  def status_title(listing, locale)
    status =
      if listing.approval_pending? || listing.approval_rejected?
        listing.state
      elsif listing.valid_until && listing.valid_until < DateTime.current
        'expired'
      else
        listing.open? ? 'open' : 'closed'
      end
    I18n.t("admin.communities.listings.#{status}", locale: locale)
  end

  def category_title(id, categories)
    out = []
    record = categories[id]
    while record
      out << record[:name]
      record = categories[record[:parent]]
    end
    out.reverse.join(" | ")
  end

  def main_image_url(listing)
    listing.listing_images.first&.image&.url
  end
end
