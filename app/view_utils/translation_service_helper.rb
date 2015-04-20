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

  # In: { "foo" => { "en" => "en foo", "fi" => "fi foo"},
  #       "bar" => { "en" => "en bar", "fi" => "fi bar"} }
  #
  # Out: [{translation_key: "foo", translations:
  #         [ {locale: "en", translation: "en foo"}, {locale: "fi", translation: "fi foo"}]},
  #       {translation_key: "bar", translations:
  #         [ {locale: "en", translation: "en bar"}, {locale: "fi", translation: "fi bar"}] }]
  def to_per_key_translations(key_locale_hash)
    key_locale_hash.map { |key, key_ts|
      { translation_key: key, translations: key_ts.map { |loc, t|
          t.present? ? { locale: loc, translation: t } : nil
        }.compact }}
  end
end
