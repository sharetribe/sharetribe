object @person
attributes :id, :username, :given_name, :family_name

node do |person|
  node :picture_url do |person|
    ensure_full_image_url(person.image.url(:medium))
  end
  
  node :thumbnail_url do |person|
     ensure_full_image_url(person.image.url(:thumb))
  end
end
