namespace :donalo do
  COMMUNITY_ID = 1

  desc "Override translations with Donalo's custom ones"
  task override_translations: :environment do
    translate(locale: 'es', key: 'homepage.filters.grid_button', value: 'foo')
    translate(locale: 'es', key: 'homepage.filters.list_button', value: 'bar')
    translate(locale: 'es', key: 'homepage.filters.map_button', value: 'lola')
  end

  def translate(locale:, key:, value:)
    attrs = { locale: locale, translation: value }
    TranslationServiceHelper.translation_hashes_to_tr_key!([attrs], COMMUNITY_ID, key)
  end
end
