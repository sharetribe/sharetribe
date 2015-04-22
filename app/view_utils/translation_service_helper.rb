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

  # Transform pipe:
  #
  # tr_key_to_hash
  #   -> View constructs the form from the hash
  #     -> from_to_hash
  #       -> hash_to_tr_key!

  # In:
  #   tr_key: 1234-aabb-ccdd,
  #
  # Out:
  #   [
  #     {locale: "en", translation: "Buy"},
  #     {locale: "fi", translation: "Myy"},
  #   ]
  #
  def tr_key_to_hashes(tr_key, locales)
    locales.map { |locale|
      {locale: locale, translation: I18n.translate(tr_key, locale: locale)}
    }
  end

  # In:
  #   { en: "Buy", fi: "Myy" }
  #
  # Out:
  #   [
  #     {locale: "en", translation: "Buy"},
  #     {locale: "fi", translation: "Myy"}
  #   ]
  def form_values_to_hashes(form)
    form.map { |locale, translation|
      {locale: locale, translation: translation}
    }
  end

  # In:
  #   [
  #     {locale: "en", translation: "Buy"},
  #     {locale: "fi", translation: "Myy"},
  #   ]
  #
  # Out: <tr_key>
  #
  def hashes_to_tr_key!(hash, community_id, tr_key = nil)
    TranslationService::API::Api.translations.create(
     community_id,
     [ { translations: hash} ]
    ).data.first[:translation_key]
  end
end
