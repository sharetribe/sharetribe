object @person
attributes :id, :username, :given_name, :family_name

node do |person|
  node :picture_url do |person|
    request.protocol + request.host_with_port + person.image.url(:medium)
  end
  
  node :thumbnail_url do |person|
    request.protocol + request.host_with_port + person.image.url(:thumb)
  end
end
