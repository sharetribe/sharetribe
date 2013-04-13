object @community

attributes :id, :name, :slogan, :description, :custom_color1, :custom_color2, :payments_in_use, :available_currencies, :join_with_invite_only, :members_count, :service_logo_style


node do |community|
  node :domain do |community|
    community.full_domain
  end
  
  node :service_name do |community|
    community.service_name
  end
  
  node :logo_url do |community|
    ensure_full_image_url(community.logo.url(:header))
  end
  
  node :cover_photo_url do |community|
    ensure_full_image_url(community.cover_photo.url(:header))
  end
end

child :location => :location do
  extends "api/locations/show"
end

node :categories_tree do |community|
  community.categories_tree
end