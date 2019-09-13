module ActiveStorageVariantPrefix
  # make "sites/sitename/variants/object-id"
  def variants_prefix(key)
    parts = key.split('/')
    parts.insert(-2, 'variants').join('/')
  end
end

ActiveStorage::Variant.class_eval do
  include ActiveStorageVariantPrefix

  def key
    "#{variants_prefix(blob.key)}/#{Digest::SHA256.hexdigest(variation.key)}"
  end
end

ActiveStorage::Blob.class_eval do
  include ActiveStorageVariantPrefix

  def delete
    service.delete(key)
    service.delete_prefixed("#{variants_prefix(key)}/") if image?
  end
end

