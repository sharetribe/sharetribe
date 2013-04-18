#object false
collection @classifications 

node :name do |clas|
  clas.name
end

node :translated_name do |clas|
  clas.display_name
end

node :description do |clas|
  clas.description
end
