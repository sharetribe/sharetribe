Given(/^community "(.*?)" has a listing shape offering services per hour$/) do |community_name|
  community = Community.where(ident: community_name).first
  transaction_process = TransactionProcess.where(community_id: community, process: :preauthorize).first
  cached_translations = TranslationService::API::Api.translations.create(
    community.id,
    [
      { translations: [ { locale: "en", translation: "Offering Services" }] },
      { translations: [ { locale: "en", translation: "Request Services" }] }
    ]
  )
  name_tr_key, action_button_tr_key = cached_translations[:data].map { |translation| translation[:translation_key] }

  listing_shape = FactoryGirl.create(:listing_shape, community: community,
                                                     transaction_process: transaction_process,
                                                     price_enabled: true,
                                                     shipping_enabled: false,
                                                     availability: 'booking',
                                                     name: 'offering',
                                                     name_tr_key: name_tr_key,
                                                     action_button_tr_key: action_button_tr_key)
  FactoryGirl.create(:listing_unit, listing_shape_id: listing_shape.id)

  Category.where(community: community).find_each do |category|
    listing_shape.categories << category
  end
end

