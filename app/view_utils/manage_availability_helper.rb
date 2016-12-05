module ManageAvailabilityHelper

  module_function

  def availability_props(community:, listing:)

    {
      i18n: {
        locale: I18n.locale,
        default_locale: I18n.default_locale,
        locale_info: I18nHelper.locale_info(Sharetribe::AVAILABLE_LOCALES, I18n.locale)
      },
      marketplace: {
        marketplace_color1: CommonStylesHelper.marketplace_colors(community)[:marketplace_color1],
      },
      listing: {
        title: listing.title,
        image_url: path_to_listing_image(listing),
      }
    }
  end

  def path_to_listing_image(listing)
    Maybe(listing.listing_images.first)
      .select(&:image_ready?)
      .image.url(:square)
      .or_else(nil)
  end

end
