module ListingsHelper

  # Class is selected if conversation type is currently selected
  def get_map_tab_class(tab_name)
    current_tab_name = action_name || "map_view"
    "inbox_tab_#{current_tab_name.eql?(tab_name) ? 'selected' : 'unselected'}"
  end

  # Class is selected if listing type is currently selected
  def get_new_listing_tab_class(listing_type)
    "new_listing_form_tab_#{@listing.listing_type.eql?(listing_type) ? 'selected' : 'unselected'}"
  end

  # Class is selected if category is currently selected
  def get_type_select_icon_class(category)
    "listing_type_select_icon_#{@listing.category.name.eql?(category) ? 'selected' : 'unselected'}_#{category}"
  end

  # Removes extra characters from datetime_select field
  def clear_datetime_select(&block)
    time = "</div><div class='date_select_time_container'><div class='datetime_select_time_label'>#{t('listings.form.departure_time.at')}:</div>"
    colon = "</div><div class='date_select_time_container'><div class='datetime_select_colon_label'>:</div>"
    haml_concat capture_haml(&block).gsub(":", "#{colon}").gsub("&mdash;", "#{time}").gsub("\n", '').html_safe
  end

  # Class is selected if listing type is currently selected
  def get_listing_tab_class(tab_name)
    current_tab_name = params[:type] || "list_view"
    "inbox_tab_#{current_tab_name.eql?(tab_name) ? 'selected' : 'unselected'}"
  end

  def visibility_array
    array = []
    Listing::VALID_VISIBILITIES.each do |visibility|
      if visibility.eql?("this_community")
        array << [t(".#{visibility}", :community => @current_community.name), visibility]
      else
        array << [t(".#{visibility}"), visibility]
      end
    end
    return array
  end

  def privacy_array
    Listing::VALID_PRIVACY_OPTIONS.collect { |option| [t(".#{option}"), option] }
  end

  def listed_listing_share_type(listing)
    if listing.share_type && listing.share_type.parent
      if listing.share_type.name.eql?("offer_to_swap") || listing.share_type.name.eql?("request_to_swap")
        t("listings.show.#{listing.category.name}_#{listing.listing_type}_#{listing.share_type.name}", :default => listing.share_type.display_name.capitalize)
      else
        localized_share_type_label(listing.share_type).mb_chars.capitalize.to_s
      end
    else
      t("listings.show.#{listing.category.name}_#{listing.listing_type}", :default => listing.share_type.display_name)
    end
  end

  def listed_listing_title(listing)
    listed_listing_share_type(listing) + ": #{listing.title}"
  end

  def share_type_url(listing, map=false)
    root_path(:share_type => listing.share_type.name, :category => listing.category.name, :map => map)
  end

  # expects category to be "item", "favor", "rideshare" or "housing"
  def localized_category_label(category)
    return nil if category.nil?
    if category.class == String
      category += "s" if ["item", "favor"].include?(category)
      return t("listings.index.#{category}", :default => category.capitalize)
    else
      return category.display_name.capitalize
    end
  end

  def localized_share_type_label(share_type)
    return nil if share_type.nil?
    return share_type.display_name.capitalize
  end

  def localized_listing_type_label(listing_type_string)
    return nil if listing_type_string.nil?
    return t("listings.show.#{listing_type_string}", :default => listing_type_string.capitalize)
  end

  def listing_form_menu_title(attribute)
    # - if
    # t(".what_kind_of_category", :category => t(".#{category}_with_article", :default => t(".listing")))
  end

  def listing_form_menu_titles(community_attribute_values)
    titles = {
      "listing_type" => t(".what_do_you_want_to_do"),
      "category" => {
        "offer" => t(".what_can_you_offer"),
        "request" => t(".what_do_you_need"),
        "default" => t(".select_category")
      },
      "subcategory" => Hash[community_attribute_values["category"].collect { |category| [category, t(".what_kind_of_#{category}", :default => t(".which_subcategory"))]}],
      "share_type" => {
        "offer" => t(".how_do_you_want_to_share_it"),
        "request" => t(".how_do_you_want_to_get_it")
      }
    }
  end

  def major_currencies(hash)
    hash.inject([]) do |array, (id, attributes)|
      array ||= []
      array << [attributes[:iso_code]]
      array.sort
    end.compact.flatten
  end

  def price_as_text(listing)
    money_without_cents_and_with_symbol(listing.price).upcase +
    unless listing.quantity.blank? then " / #{listing.quantity}" else "" end +
    if @current_community.vat then " " + t("listings.displayed_price.price_excludes_vat") else "" end
  end

  def is_image_processing?(listing)
    with_first_listing_image(listing) do |first_image|
      first_image.image_processing
    end
  end

  def has_images?(listing)
    !listing.listing_images.empty?
  end

  def with_image_frame(listing, &block)
    if self.has_images?(listing) then
      first_image = listing.listing_images.first
      if first_image.image_processing then
        block.call(:image_processing, nil)
      else
        block.call(:image_ok, first_image)
      end
    elsif listing.description.blank? then
      block.call(:no_description, nil)
    end
  end

  def aspect_ratio_class(image)
    aspect_ratio = 3/2.to_f
    if image.correct_size? aspect_ratio
      "correct-ratio"
    elsif image.too_narrow? aspect_ratio
      "too-narrow"
    else
      "too-wide"
    end
  end
end
