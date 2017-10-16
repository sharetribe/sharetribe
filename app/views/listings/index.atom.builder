atom_feed :language => 'en-US', 'xmlns:georss' => 'http://www.georss.org/georss', 'xmlns:st'  => 'http://www.sharetribe.com/SharetribeFeed' do |feed|
  feed.title @feed_presenter.title
  feed.updated @feed_presenter.updated
  feed.icon "https://s3.amazonaws.com/sharetribe/assets/sharetribe_icon.png"
  feed.logo "https://s3.amazonaws.com/sharetribe/assets/dashboard/sharetribe_logo.png"

  @feed_presenter.listings.each do |listing|
    feed.entry(nil, id: listing[:id], published: listing[:created_at], updated_at: listing[:updated_at], url: listing_url(listing[:url], host: @current_community.full_domain(port: ''))) do |entry|
      entry.title format_listing_title(listing[:shape_name_tr_key], listing[:title])
      entry_content = add_links_and_br_tags(html_escape(listing[:description]))
      unless listing[:listing_images].empty?

        img_url = ensure_full_image_url(listing[:listing_images].first[:medium])

        entry_content +=  "<br />\n" + link_to(image_tag(img_url), listing_url(listing[:url], host: @current_community.full_domain(port: '')))
      end

      entry.content :type => 'html' do |content|
        entry.cdata!( entry_content )
      end

      entry.st :listing_type, :term => @feed_presenter.direction_map[listing[:listing_shape_id]], :label => localized_listing_type_label(@feed_presenter.direction_map[listing[:listing_shape_id]])

        # TODO: add scheme link to point to url where that category of that community is shown
      entry.category :term => listing[:category_id], :label => localized_category_from_id(listing[:category_id])


      entry.st :share_type, :term => listing[:listing_shape_id], :label => t(listing[:shape_name_tr_key]).capitalize if listing[:shape_name_tr_key]

      entry.author do |author|
        author.name PersonViewUtils.person_entity_display_name(listing[:author], @current_community.name_display_type)
      end

      if listing[:latitude] || listing[:longitude] || listing[:address]
        entry.georss :point, "#{listing[:latitude]} #{listing[:longitude]}"
        entry.st :address, listing[:address]
      end

      entry.st :comment_count, listing[:comment_count]
    end
  end
end
