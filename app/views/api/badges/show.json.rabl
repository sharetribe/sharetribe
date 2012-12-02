object @badge
attributes :id, :name, :created_at

node :picture_url do |badge|
  request.protocol + request.host_with_port + "/assets/badges/#{badge.name}_large.png"
end

node :description do |badge|
  t("people.profile_badge.#{badge.name}_description")
end

