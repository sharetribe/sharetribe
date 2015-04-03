module TranslationServiceHelper

  module_function

  def pick_translation(key, community_translations, community_locales, user_locale, opts = {})
    translations_for_key = community_translations.select { |translation| translation[:translation_key] == key }

    raise ArgumentError.new("Can not find any translation for key: #{key}") if translations_for_key.empty?

    preferred = (opts[:locale] || user_locale).to_s
    fallbacks = community_locales.map(&:to_s).reject { |l| l == preferred }
    locales_ordered = [preferred].concat(fallbacks)

    translations_ordered = locales_ordered.map { |l|
      translations_for_key.find { |t| t[:locale] == l }
    }

    (translations_ordered.first || translations_for_key.first)[:translation]
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
