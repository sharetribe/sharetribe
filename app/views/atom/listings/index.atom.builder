atom_feed :language => 'en-US', 'xmlns:georss' => 'http://www.georss.org/georss', 'xmlns:st'  => 'http://www.sharetribe.com/SharetribeFeed' do |feed|
  feed.title @title
  feed.updated @updated
  feed.icon "https://s3.amazonaws.com/sharetribe/assets/sharetribe_icon.png"
  feed.logo "https://s3.amazonaws.com/sharetribe/assets/dashboard/sharetribe_logo.png"

  @listings.each do |listing|
    feed.entry( listing, url: listing_url(listing, host: @current_community.full_domain(port: ''))) do |entry|
      entry.title listed_listing_title(listing)
      entry_content = add_links_and_br_tags(html_escape(listing.description))
      unless listing.listing_images.empty?

        img_url = ensure_full_image_url(listing.listing_images.first.image.url(:medium))

        # disable enclosure link to avoid double pictures
        #entry.link :href => img_url, :rel => "enclosure", :type  => listing.listing_images.first.image_content_type
        entry_content +=  "<br />\n" + link_to(image_tag(img_url), listing_url(listing, host: @current_community.full_domain(port: '')))
      end

      entry.content :type => 'html' do |content|
        entry.cdata!( entry_content )
      end

      # the strftime is needed to work with Google Reader.
      #entry.updated(listing.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ"))

      entry.st :listing_type, :term => listing.direction, :label => localized_listing_type_label(listing.direction)

        # TODO: add scheme link to point to url where that category of that community is shown
      entry.category :term => listing.category.id, :label => localized_category_label(listing.category)


      entry.st :share_type, :term => listing.transaction_type.id, :label => localized_transaction_type_label(listing.transaction_type).capitalize if listing.transaction_type

      entry.author do |author|
        author.name listing.author.name_or_username
      end

      if listing.location
        entry.georss :point, "#{listing.location.latitude} #{listing.location.longitude}"
        entry.st :address,  listing.location.address
      end



      entry.st :comment_count, listing.comments.count
      entry.st :visibility, listing.visibility
    end
  end
end