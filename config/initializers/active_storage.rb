module ActiveStorage
  Variant.class_eval do
    # Returns a combination key of the blob and the variation that together identifies a specific variant.
    def key
      parts = blob.key.split('/')
      # make "sites/zzz/variants/tMXJRgNDNWbUykwzvVh1nNgs"
      beginning = parts.insert(-2, 'variants').join('/')
      "#{beginning}/#{Digest::SHA256.hexdigest(variation.key)}"
    end
  end
end
