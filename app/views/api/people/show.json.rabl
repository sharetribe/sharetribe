object @person
attributes :id, :username, :given_name, :family_name, :locale, :phone_number, :description

node :communities do |person|
  person.communities.map do |community|
    partial 'api/communities/show', :object => community, :root => false
  end
end