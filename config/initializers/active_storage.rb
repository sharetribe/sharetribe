module ActiveStorage
  Variant.class_eval do
    # Returns a combination key of the blob and the variation that together identifies a specific variant.
    def key
      "#{blob.key}/variants/#{Digest::SHA256.hexdigest(variation.key)}"
    end
  end
end
