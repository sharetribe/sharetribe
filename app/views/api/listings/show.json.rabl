object @listing
attributes :id, :title, :description, :status,
           :times_viewed, :privacy,
           :price_cents, :currency, :quantity,
           :created_at, :updated_at, :valid_until
           
node do |listing|
  if listing.listing_images.present?
    node :thumbnail_url do |listing|
      ensure_full_image_url(listing.listing_images.first.image.url(:thumb))
    end

    node :image_urls do |listing|
      listing.listing_images.map do |i|
        ensure_full_image_url(i.image.url(:medium))
      end
    end
  end
  
  node :visibility do |listing|
    if api_version_alpha? && listing.visibility == "all_communities"
      "everybody"
    else
      listing.visibility
    end
  end
  
  node :listing_type do |listing|
    listing.direction
  end
  
  # Deprecated: share_type is renamed to transaction_type.
  node :share_type do |listing|
    if api_version_alpha? 
      if listing.transaction_type.api_name.match(/swap$/)
        # Change to old string
        "trade"
      elsif ! listing.transaction_type.api_name.match(/^give_away$|^lend$|^rent_out$|^sell$|^share_for_free$|^trade$|^borrow$|^buy$|^rent$|^trade$|^take_for_free$/)
        # If not one of those that the iOS app can translate
        nil
      else
        listing.transaction_type.api_name
      end
    else
      listing.transaction_type.api_name
    end
  end
  
  node :category do |listing|
    if api_version_alpha?
      listing.category.top_level_parent.name
    else
      listing.category.id
    end
  end
end

child :author => :author do 
  extends "api/people/show"
end

child :origin_loc => :origin_location do
  extends "api/locations/show"
end

node :tags do |listing|
  listing.tags.map do |tag|
    tag.name
  end
end

node :comments do |listing|
  listing.comments.map do |comment|
    partial "api/comments/show", :object => comment, :root => false
  end
end