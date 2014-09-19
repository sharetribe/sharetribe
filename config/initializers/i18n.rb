I18n.backend.class.send(:include, I18n::Backend::Fallbacks)
I18n.fallbacks.map('fi' => 'en')
I18n.fallbacks.map('ru' => 'en')
I18n.fallbacks.map('nl' => 'en')
I18n.fallbacks.map('sw' => 'en')
I18n.fallbacks.map('el' => 'en')
I18n.fallbacks.map('ro' => 'en')
I18n.fallbacks.map('fr' => 'en')
I18n.fallbacks.map('es' => 'en')
I18n.fallbacks.map('es-ES' => 'es')
I18n.fallbacks.map('ca' => 'es-ES')
I18n.fallbacks.map('zh' => 'en')
I18n.fallbacks.map('it' => 'en')

I18n.fallbacks.map('en-rc' => 'en')
I18n.fallbacks.map('es-rc' => 'es-ES')
I18n.fallbacks.map('fr-rc' => 'fr')
I18n.fallbacks.map('de-rc' => 'de')
I18n.fallbacks.map('en-ul' => 'en')
I18n.fallbacks.map('en-bf' => 'en')
I18n.fallbacks.map('en-bd' => 'en')
I18n.fallbacks.map('fr-bd' => 'fr')
I18n.fallbacks.map('en-cf' => 'en')
I18n.fallbacks.map('en-vg' => 'en')
I18n.fallbacks.map('en-un' => 'en')
I18n.fallbacks.map('en-bl' => 'en')
I18n.fallbacks.map('de-bl' => 'de')
I18n.fallbacks.map('en-qr' => 'en')
I18n.fallbacks.map('en-at' => 'en')
I18n.fallbacks.map('fr-at' => 'fr')

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
