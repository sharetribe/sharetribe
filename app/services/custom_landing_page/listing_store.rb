module CustomLandingPage
  module ListingStore

    module_function

    def listing(community_id:, landing_page_locale:, locale_param:, name_display_type:, id:)

      listing = Listing.includes(:author).find_by(community_id: community_id, id: id)

      if listing
        # Check that image is processed and downloaded before using it
        listing_image = Maybe(listing.listing_images.first)
                        .select { |img| img.image_ready? }
                        .map { |img| img.image.url(:big) }
                        .or_else(nil)

        author = listing.author

        # Check that author avatar is processed
        author_avatar =
          if author.image.present? && !author.image.processing?
            author.image.url(:thumb)
          end

        {
          "title" => listing.title,
          "price" => Maybe(listing.price).format(no_cents_if_whole: true).or_else(nil),
          "price_unit" => Maybe(listing.unit_type).map { |unit_type| ListingViewUtils.translate_unit(unit_type, listing.unit_tr_key, locale: landing_page_locale) }.or_else(nil),
          "shape_name" => I18n.t(listing.shape_name_tr_key, locale: landing_page_locale),
          "author_name" => PersonViewUtils.display_name(
            first_name: author.given_name,
            last_name: author.family_name,
            display_name: author.display_name,
            username: author.username,
            name_display_type: name_display_type,
            is_deleted: author.deleted?,
            deleted_user_text: I18n.translate("common.removed_user")
          ),
          "author_avatar" => author_avatar,
          "listing_image" => listing_image,
          "listing_path" => listing_path(listing.id, locale_param),
          "author_path" => author_path(author.username, locale_param)
        }
      end
    end

    # private

    def author_path(username, locale_param)
      paths.person_path(username: username, locale: locale_param)
    end

    def listing_path(id, locale_param)
      paths.listing_path(id: id, locale: locale_param)
    end


    def paths
      @_url_helpers ||= Rails.application.routes.url_helpers
    end
  end
end
