# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone
Mime::Type.register "image/heic", :heic, [], %w(heic)
Mime::Type.register "image/heif", :heif, [], %w(heif)

type = MIME::Type.new('image/heic')
type.registered = true
type.extensions = ['heic']
MIME::Types.add(type)

type = MIME::Type.new('image/heif')
type.registered = true
type.extensions = ['heif']
MIME::Types.add(type)
