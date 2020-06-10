namespace :donalo do
  COMMUNITY_ID = 1

  desc "Override translations with Donalo's custom ones"
  task override_translations: :environment do
    attrs = { locale: 'es', translation: 'foo' }
    translate(attrs, 'homepage.filters.grid_button')

    attrs = { locale: 'es', translation: 'bar' }
    translate(attrs, 'homepage.filters.list_button')

    attrs = { locale: 'es', translation: 'lol' }
    translate(attrs, 'homepage.filters.map_button')
  end

  def translate(copy, key)
    TranslationServiceHelper.translation_hashes_to_tr_key!([copy], COMMUNITY_ID, key)
  end
end
