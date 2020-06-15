category = Category.find_or_create_by(url: 'mobiliario') do |category|
  category.community_id = 1
end
category.translations.find_or_create_by(name: 'Mobiliari') do |translation|
  translation.locale = 'ca'
end
category.translations.find_or_create_by(name: 'Mobiliario') do |translation|
  translation.locale = 'es'
end

category = Category.find_or_create_by(url: 'material-de-oficina') do |category|
  category.community_id = 1
end
category.translations.find_or_create_by(name: "Material d'oficina") do |translation|
  translation.locale = 'ca'
end
category.translations.find_or_create_by(name: 'Material de oficina') do |translation|
  translation.locale = 'es'
end

category = Category.find_or_create_by(url: 'material-escolar') do |category|
  category.community_id = 1
end
category.translations.find_or_create_by(name: 'Material escolar') do |translation|
  translation.locale = 'ca'
end
category.translations.find_or_create_by(name: 'Material escolar') do |translation|
  translation.locale = 'es'
end

category = Category.find_or_create_by(url: 'material-de-construccion') do |category|
  category.community_id = 1
end
category.translations.find_or_create_by(name: 'Material de construcció') do |translation|
  translation.locale = 'ca'
end
category.translations.find_or_create_by(name: 'Material de construccion') do |translation|
  translation.locale = 'es'
end

category = Category.find_or_create_by(url: 'hogar-y-jardin') do |category|
  category.community_id = 1
end
category.translations.find_or_create_by(name: 'Llar i jardí') do |translation|
  translation.locale = 'ca'
end
category.translations.find_or_create_by(name: 'Hogar y jardín') do |translation|
  translation.locale = 'es'
end

category = Category.find_or_create_by(url: 'electrodomesticos') do |category|
  category.community_id = 1
end
category.translations.find_or_create_by(name: 'Electrodomèstics') do |translation|
  translation.locale = 'ca'
end
category.translations.find_or_create_by(name: 'Electrodomesticos') do |translation|
  translation.locale = 'es'
end

category = Category.find_or_create_by(url: 'informatica') do |category|
  category.community_id = 1
end
category.translations.find_or_create_by(name: 'Informàtica') do |translation|
  translation.locale = 'ca'
end
category.translations.find_or_create_by(name: 'Informatica') do |translation|
  translation.locale = 'es'
end

category = Category.find_or_create_by(url: 'electronica') do |category|
  category.community_id = 1
end
category.translations.find_or_create_by(name: 'Electrònica') do |translation|
  translation.locale = 'ca'
end
category.translations.find_or_create_by(name: 'Electronica') do |translation|
  translation.locale = 'es'
end

category = Category.find_or_create_by(url: 'libros-cine-y-musica') do |category|
  category.community_id = 1
end
category.translations.find_or_create_by(name: 'Llibres, cinema i música') do |translation|
  translation.locale = 'ca'
end
category.translations.find_or_create_by(name: 'Libros, cine y música') do |translation|
  translation.locale = 'es'
end

category = Category.find_or_create_by(url: 'productos-de-limpieza') do |category|
  category.community_id = 1
end
category.translations.find_or_create_by(name: 'Productes de neteja') do |translation|
  translation.locale = 'ca'
end
category.translations.find_or_create_by(name: 'Productos de limpieza') do |translation|
  translation.locale = 'es'
end

category = Category.find_or_create_by(url: 'otros') do |category|
  category.community_id = 1
end
category.translations.find_or_create_by(name: 'Altres') do |translation|
  translation.locale = 'ca'
end
category.translations.find_or_create_by(name: 'Otros') do |translation|
  translation.locale = 'es'
end

category = Category.find_or_create_by(url: 'accesorios-y-ropa') do |category|
  category.community_id = 1
end
category.translations.find_or_create_by(name: 'Accessoris i roba') do |translation|
  translation.locale = 'ca'
end
category.translations.find_or_create_by(name: 'Accesorios y ropa') do |translation|
  translation.locale = 'es'
end
