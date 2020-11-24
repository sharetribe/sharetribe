# Add fallbacks module to the current backend (which in this point is Simple backend)
I18n.backend.class.send(:include, I18n::Backend::Fallbacks)

# Configure the available locales
I18n.available_locales = Sharetribe::AVAILABLE_LOCALES.map { |locale| locale[:ident] }

# Implement a custom Tag implementation.
#
# The default I18n::Locale::Tag::Simple implementation splits the locale by dashes
# and returns an array. For example:
#
# I18n.fallbacks["da-DK"] #=> [:"da-DK", :da, :en]
#
# This is a problem for us, because we have manually defined what locales are available.
# We do have "da-DK" locale, but we don't have "da" locale.
#
# The I18n::Locale::Tag::DefinedFallbacksOnly is a slightly modified version of Simple
# implementation. The only difference is that the `to_a` method returns the current
# tag only (in an array) without splitting it:
#
# I18n::Locale::Tag.implementation = I18n::Locale::Tag::DefinedFallbacksOnly
# I18n.fallbacks["da-DK"] #=> [:"da-DK", :en]
#
# Read more:
#
# - The Simple implementation: https://github.com/svenfuchs/i18n/blob/aee7b3f6072fba3f54798a280bd6007536b039cd/lib/i18n/locale/tag/simple.rb
# - RFC 4646 standard compliance: https://github.com/svenfuchs/i18n/wiki/Fallbacks#rfc-4646-standard-compliance
#
module I18n
  module Locale
    module Tag
      class DefinedFallbacksOnly
        class << self
          def tag(tag)
            new(tag)
          end
        end

        include Parents

        attr_reader :tag

        def initialize(*tag)
          @tag = tag.join('-').to_sym
        end

        def to_sym
          tag
        end

        def to_s
          tag.to_s
        end

        def to_a
          [tag.to_s]
        end
      end
    end
  end
end

I18n::Locale::Tag.implementation = I18n::Locale::Tag::DefinedFallbacksOnly

# Set the fallback mapping
Sharetribe::AVAILABLE_LOCALES
  .select { |locale| locale[:fallback].present? }
  .each { |locale| I18n.fallbacks.map(locale[:ident] => locale[:fallback]) }

module I18n
  def self.with_locale(locale, &block)
    orig_locale = self.locale
    self.locale = locale
    return_value = yield
    self.locale = orig_locale
    return_value
  end
end

I18n.module_eval do

  class << self

    # Monkey patch the translate method to include service name options
    def translate_with_service_name(*args)
      service_name = ApplicationHelper.fetch_community_service_name_from_thread

      options  = args.last.is_a?(Hash) ? args.pop : {}

      with_service_name = if !options.key?(:service_name)
        options.merge(:service_name => service_name)
      else
        options
      end

      translate_without_service_name(*(args << with_service_name))
    end

    alias_method :translate_without_service_name, :translate # Save the original :translate to :translate_without_service_name
    alias_method :translate, :translate_with_service_name    # Make :translate to point to :translate_with_service_name
  end
end

# Pluralization monkey patch
# Pluralizer is selected by language code, but I18n gem doesn't understand two-part locales
# we use for many locales. Default fallback is "one-other" pluralisation, but Turkish needs
# an "other" type pluralizer.
#
# This should be generalized to drop the region code from two-part locales.
module I18n::Backend::Pluralization
  alias_method :pluralizer_original, :pluralizer
  def pluralizer(locale)
    if (locale == :'tr-TR')
      original_locales = I18n.available_locales
      I18n.available_locales += [:tr]
      p = pluralizer_original('tr')
      I18n.available_locales = original_locales
      p
    else
      pluralizer_original(locale)
    end
  end
end

# Throw en exception in test mode if translation is missing.
# See: http://robots.thoughtbot.com/foolproof-i18n-setup-in-rails
#
# Because of some weird stuff happening in TranslationHelper (setting raise_error weirdly...?) the "Rails 3" part
# from the foolproof 18n setup guide did not work.
#
if Rails.env.test?
  module ActionView::Helpers::TranslationHelper
    def t_with_raise(*args)
      value = t_without_raise(*args)

      if value.to_s.match(/title="translation missing: (.+)"/)
        raise "Translation missing: #{$1}"
      else
        value
      end
    end

    alias_method :t_without_raise, :t       # Save the original :t to :t_without_raise
    alias_method :t, :t_with_raise          # Make :t to point to :t_with_raise
    alias_method :translate, :t_with_raise  # Make :translate to point to :t_with_raise
  end
end
