I18n.backend.class.send(:include, I18n::Backend::Fallbacks)
I18n.fallbacks.map('ru' => 'en')
I18n.fallbacks.map('nl' => 'en')
I18n.fallbacks.map('sw' => 'en')
I18n.fallbacks.map('el' => 'en')
I18n.fallbacks.map('ro' => 'en')

module I18n
  def self.with_locale(locale, &block)
    orig_locale = self.locale
    self.locale = locale
    return_value = yield
    self.locale = orig_locale
    return_value
  end
end