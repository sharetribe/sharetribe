module TranslationServiceHelper

  module_function

  def community_translations_for_i18n_backend(translations)
    locale_groups = translations.group_by { |tr| tr[:locale] }
    locale_groups.map { |(locale, translations)|
      [locale.to_sym, translations.inject({}) { |memo, tr|
         memo.tap { |m| m[tr[:translation_key]] = tr[:translation] }
       }]
    }
  end

  # In: [{translation_key: "foo", locale: "en", translation: "en foo"},
  #      {translation_key: "foo", locale: "fi", translation: "fi foo"},
  #      {translation_key: "bar", locale: "en", translation: "en bar"},
  #      {translation_key: "bar", locale: "fi", translation: "fi bar"}]
  #
  # Out: { "foo" => { "en" => "en foo", "fi" => "fi foo"},
  #        "bar" => { "en" => "en bar", "fi" => "fi bar"} }
  def to_key_locale_hash(ts)
    ts.group_by { |t| t[:translation_key] }
      .map { |key, key_ts| [key, key_ts.group_by { |t| t[:locale] }]}
      .map { |key, key_ts| [key, key_ts.map { |loc, t| [loc, t.first[:translation]]}.to_h]}
      .to_h
  end

  # In: { "foo" => { "en" => "en foo", "fi" => "fi foo"},
  #       "bar" => { "en" => "en bar", "fi" => "fi bar"} }
  #
  # Out: [{translation_key: "foo", translations:
  #         [ {locale: "en", translation: "en foo"}, {locale: "fi", translation: "fi foo"}]},
  #       {translation_key: "bar", translations:
  #         [ {locale: "en", translation: "en bar"}, {locale: "fi", translation: "fi bar"}] }]
  #
  # Note! This is a not a reverse of to_key_locale_hash
  def to_per_key_translations(key_locale_hash)
    key_locale_hash.map { |key, key_ts|
      { translation_key: key, translations: key_ts.map { |loc, t|
          t.present? ? { locale: loc, translation: t } : nil
        }.compact }}
  end
end
