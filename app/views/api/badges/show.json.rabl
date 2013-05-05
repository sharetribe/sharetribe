object @badge
attributes :id, :name, :created_at

node :picture_url do |badge|
  "https://s3.amazonaws.com/sharetribe/assets/images/badges/#{badge.name}_large.png"
end

node :description do |badge|
  t("people.profile_badge.#{badge.name}_description")
end

