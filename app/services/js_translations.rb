module JSTranslations
  module_function

  # Give array of keys and get back hash of translated but uninterpolated key/value hash.
  # This value can be converted `to_json` and passed to JavaScript.
  #
  # See more:
  # - application_helper#js_t
  # - translations.js
  #
  def load(keys)
    without_interpolation {
      keys.inject({}) do |memo, key|
        raise "Use only full keys, not keys scoped by partial: '#{key}'" if key.to_s.first == "."
        memo[key] = I18n.t(key)
        memo
      end
    }
  end

  # Disable MissingInterpolationArgument error
  def without_interpolation(&block)
    default_handler = I18n.config.missing_interpolation_argument_handler
    I18n.config.missing_interpolation_argument_handler = ->(missing_key, provided_hash, string) { "${#{missing_key}}" }
    result = block.call()
    I18n.config.missing_interpolation_argument_handler = default_handler
    result
  end
end
