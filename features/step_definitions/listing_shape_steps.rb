Given(/^community "(.*?)" has order type "(.*?)"$/) do |community, order_type|
  community = Community.where(ident: community).first
  FactoryGirl.create(:listing_shape, community: community,
                                     transaction_process: FactoryGirl.create(:transaction_process),
                                     name: order_type)
end

Given(/^community "(.*?)" has a listing shape offering services per hour$/) do |community_name|
  community = Community.where(ident: community_name).first
  create_listing_shape(
    community: community,
    name: 'offering',
    availability: 'booking',
    name_translation: 'Offering Services',
    button_translation: 'Request Services',
    unit_types: [ 'hour' ]
  )
end

Given(/^community "(.*?)" has a listing shape offering services per hour, day, night, week, month$/) do |community_name|
  community = Community.where(ident: community_name).first
  create_listing_shape(
    community: community,
    name: 'offering',
    availability: 'booking',
    name_translation: 'Offering Services',
    button_translation: 'Request Services',
    unit_types: [ 'hour', 'day', 'night', 'week', 'month' ]
  )
end

def create_listing_shape(community:, name:, availability:, name_translation:, button_translation:, unit_types:)
  transaction_process = TransactionProcess.where(community_id: community, process: :preauthorize).first
  cached_translations = TranslationService::API::Api.translations.create(
    community.id,
    [
      { translations: [ { locale: "en", translation: name_translation }] },
      { translations: [ { locale: "en", translation: button_translation }] }
    ]
  )
  name_tr_key, action_button_tr_key = cached_translations[:data].map { |translation| translation[:translation_key] }

  listing_shape = FactoryGirl.create(:listing_shape, community: community,
                                                     transaction_process: transaction_process,
                                                     price_enabled: true,
                                                     shipping_enabled: false,
                                                     availability: availability,
                                                     name: name,
                                                     name_tr_key: name_tr_key,
                                                     action_button_tr_key: action_button_tr_key)
  create_unit_types(listing_shape, unit_types)

  Category.where(community: community).find_each do |category|
    listing_shape.categories << category
  end
end

# creates listing unit with
# quantity_selector   'number'
# kind                'time'
def create_unit_types(listing_shape, unit_types)
  unit_types && unit_types.each do |unit_type|
    FactoryGirl.create(:listing_unit, listing_shape_id: listing_shape.id, unit_type: unit_type)
  end
end

