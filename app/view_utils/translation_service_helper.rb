module TranslationServiceHelper

  module_function

  def community_translations_for_i18n_backend(translations)
    locale_groups = translations.group_by { |tr| tr[:locale] }
    locale_groups.map { |(locale, ts)|
      [locale.to_sym,
       ts.inject({}) { |memo, tr|
         memo.tap { |m| m[tr[:translation_key]] = tr[:translation] }
       }]
    }
  end

  # Usage:
  #
  # tr_keys_to_form_values(
  #   entity: { button_tr_key: '1234-aabbb-cccc' },
  #   locales: ['en', 'fi'],
  #   key_map: { button_tr_key: :button_label }
  # )
  #
  # Result:
  # {
  #   button_tr_key: '1234-aabbb-cccc',
  #   button_label: { en: 'Button', fi: 'Nappi' }
  # }
  #
  def tr_keys_to_form_values(entity:, locales:, key_map:)
    form_values = key_map.reduce({}) { |f_values, (tr_key_prop, form_name)|
      tr_key = entity[tr_key_prop]
      f_values[form_name] = tr_key_to_form_value(tr_key, locales)
      f_values
    }
    entity.merge(form_values)
  end

  # Usage (update):
  #
  # form_values_to_tr_keys!(
  #   entity: { button_tr_key: 'admin.button_label', button_label: { en: 'Button', fi: 'Nappi' } },
  #   key_map: { button_tr_key: :button_label },
  #   community_id: 123)
  #
  # Result:
  # { button_tr_key: 'admin.button_label'
  # , button_label: { en: 'Button', fi: 'Nappi' }
  # }
  #
  # Usage (new):
  #
  # form_values_to_tr_keys!(
  #   entity: { button_label: { en: 'Button', fi: 'Nappi' } },
  #   key_map: { button_tr_key: :button_label },
  #   community_id: 123)
  #
  # Result:
  # { button_tr_key: 'admin.button_label'
  # , button_label: { en: 'Button', fi: 'Nappi' }
  # }
  #
  def form_values_to_tr_keys!(entity:, key_map:, community_id:)
    key_map.each { |tr_key_prop, form_name|
      form_value = entity[form_name]
      hash = form_value_to_translation_hashes(form_value)
      entity[tr_key_prop] = translation_hashes_to_tr_key!(hash, community_id, entity[tr_key_prop])
    }
    entity
  end

  # private


  # In:
  #   tr_key: 1234-aabb-ccdd,
  #
  # Out:
  #   {
  #     "en": "Buy",
  #     "fi": "Myy"
  #   }
  #
  # If nil:
  #
  # In:
  #   tr_key: nil
  #
  # Out:
  #   {
  #     "en": "",
  #     "fi": ""
  #   }
  def tr_key_to_form_value(tr_key, locales)
    locales.reduce({}) { |memo, locale|
      memo[locale] = if tr_key.nil?
        ""
      else
        I18n.translate(tr_key, locale: locale)
      end

      memo
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
  def form_value_to_translation_hashes(form)
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
  def translation_hashes_to_tr_key!(hash, community_id, tr_key = nil)
    TranslationService::API::Api.translations.create(
     community_id,
     [ { translation_key: tr_key, translations: hash} ]
    ).data.first[:translation_key]
  end
end
