object @listing
attributes :id, :title, :description, :status, :listing_type,
           :category, :share_type, :times_viewed,
           :created_at, :updated_at, :valid_until,
           :visibility, :privacy
           
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