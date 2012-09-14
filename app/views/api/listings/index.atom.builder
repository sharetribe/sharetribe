atom_feed :language => 'en-US', 'xmlns:georss' => 'http://www.georss.org/georss' do |feed|
  feed.title @title
  feed.updated @updated
  feed.icon "https://www.sharetribe.com/images/sharetribe_icon.png"
  feed.logo "https://www.sharetribe.com/images/dashboard/sharetribe_logo.png"

  @listings.each do |listing|
    #next if listing.updated_at.blank?

    feed.entry( listing ) do |entry|
      entry.url listing_url(listing)
      entry.title listing.title
      entry.content listing.description, :type => 'html'

      # the strftime is needed to work with Google Reader.
      entry.updated(listing.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")) 

      entry.listing_type listing.listing_type
      
      entry.category do |category|
        category.term listing.category
        # TODO: add scheme link to point to url where that category of that community is shown
        
        category_label_translation_key = listing.category
        category_label_translation_key += "s" if ["item", "favor"].include?(listing.category)
        category.label t("listings.index.#{category_label_translation_key}")
      end
      
      # TODO add custom namespace for non-standard ATOM fields
      entry.share_type listing.share_type if listing.share_type
      entry.tags do |tags|
        listing.tags.each do |tag|
          tags.tag tag.name
        end
      end
      
      entry.author do |author|
        author.name listing.author.name
      end
      
      if listing.location
        entry.send "georss:point", "#{listing.location.latitude} #{listing.location.longitude}" 
        entry.address listing.location.address
      end
      
      unless listing.listing_images.empty?
        entry.link :href => listing.listing_images.first.image.url(:medium), :rel => "enclosure", :type  => listing.listing_images.first.image_content_type
      end
      
      entry.comment_count listing.comments.count
      entry.visibility listing.visibility
    end
  end
end