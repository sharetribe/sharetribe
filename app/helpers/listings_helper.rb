module ListingsHelper

  # Class is selected if conversation type is currently selected
  def get_map_tab_class(tab_name)
    current_tab_name = action_name || "map_view"
    "inbox_tab_#{current_tab_name.eql?(tab_name) ? 'selected' : 'unselected'}"
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

  def privacy_array
    Listing::VALID_PRIVACY_OPTIONS.collect { |option| [t("listings.form.#{option}"), option] }
  end

  def listed_listing_title(listing)
    listing.transaction_type.display_name(I18n.locale) + ": #{listing.title}"
  end

  def transaction_type_url(listing, view)
    root_path(:transaction_type => listing.transaction_type.id, :view => view)
  end

  def localized_category_label(category)
    return nil if category.nil?
    return category.display_name(I18n.locale).capitalize
  end

  def localized_transaction_type_label(transaction_type)
    return nil if transaction_type.nil?
    return transaction_type.display_name(I18n.locale).capitalize
  end

  def localized_listing_type_label(listing_type_string)
    return nil if listing_type_string.nil?
    return t("listings.show.#{listing_type_string}", :default => listing_type_string.capitalize)
  end

  def listing_form_menu_titles(community_attribute_values)
    titles = {
      "category" => t("listings.new.select_category"),
      "subcategory" => t("listings.new.select_subcategory"),
      "transaction_type" => t("listings.new.select_transaction_type")
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
    humanized_money_with_symbol(listing.price).upcase +
    unless listing.quantity.blank? then " / #{listing.quantity}" else "" end +
    if @current_community.vat then " " + t("listings.displayed_price.price_excludes_vat") else "" end
  end

  def has_images?(listing)
    !listing.listing_images.empty?
  end

  def with_image_frame(listing, &block)
    if self.has_images?(listing) then
      images = listing.listing_images
      if !listing.listing_images.all? { |image| image.image_ready? } then
        block.call(:images_processing, nil)
      else
        block.call(:images_ok, images)
      end
    elsif listing.description.blank? then
      block.call(:no_description, nil)
    end
  end

  def with_quantity_and_vat_text(community, listing, &block)
    buffer = []
    buffer.push(price_quantity_per_unit(listing))

    if community.vat
      buffer.push(t("listings.show.price_excludes_vat"))
    end

    block.call(buffer.join(" ")) unless buffer.empty?
  end

  def price_quantity_slash_unit(listing)
    if listing.transaction_type.price_per
      "/ " + t("unit.#{listing.transaction_type.price_per}")
    elsif listing.quantity.present?
      "/ #{listing.quantity}"
    else
      ""
    end
  end

  def price_quantity_per_unit(listing)
    if listing.transaction_type.price_per
      t("listings.show.price.per_#{listing.transaction_type.price_per}")
    elsif listing.quantity.present?
      t("listings.show.price.per_quantity_unit", quantity_unit: listing.quantity)
    else
      ""
    end
  end
end
