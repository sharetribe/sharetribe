atom_feed :language => 'en-US', 'xmlns:georss' => 'http://www.georss.org/georss', 'xmlns:st'  => 'http://www.sharetribe.com/SharetribeFeed' do |feed|
  feed.title @title
  feed.updated @updated
  feed.icon "https://www.sharetribe.com/images/sharetribe_icon.png"
  feed.logo "https://www.sharetribe.com/images/dashboard/sharetribe_logo.png"

  @listings.each do |listing|
    feed.entry( listing ) do |entry|
      entry.title listed_listing_title(listing)
      pattern = /[\.)]*$/
      entry.content :type => 'html' do |content|
        entry.cdata!( add_links_and_br_tags(html_escape(listing.description)))
      end

      # the strftime is needed to work with Google Reader.
      #entry.updated(listing.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")) 

      entry.st :listing_type, listing.listing_type

        # TODO: add scheme link to point to url where that category of that community is shown      
      entry.category :term => listing.category, :label => localized_category_label(listing.category)
        
      
      entry.st :share_type, listing.share_type if listing.share_type
      entry.st :tags do |tags|
        listing.tags.each do |tag|
          tags.st :tag, tag.name
        end
      end
      
      entry.author do |author|
        author.name listing.author.name_or_username
      end
      
      if listing.location
        entry.georss :point, "#{listing.location.latitude} #{listing.location.longitude}" 
        entry.st :address,  listing.location.address
      end
      
      unless listing.listing_images.empty?
        entry.link :href => "#{@url_root}#{listing.listing_images.first.image.url(:medium)}", :rel => "enclosure", :type  => listing.listing_images.first.image_content_type
      end
      
      entry.st :comment_count, listing.comments.count
      entry.st :visibility, listing.visibility
    end
  end
end