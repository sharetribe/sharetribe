namespace :donalo do
  COMMUNITY_ID = 1

  desc "Override translations with Donalo's custom ones"
  task override_translations: :environment do
    translate(locale: 'es', key: 'listings.listing_actions.marketplace_fees_may_apply', value: "%{service_name} aplica una cuota de servicio por transacción que contribuye a mantener la plataforma")
    translate(locale: 'ca', key: 'listings.listing_actions.marketplace_fees_may_apply', value: "%{service_name} aplica una quota de servei per transacció que contribueix a mantenir la plataforma")

    translate(locale: 'es', key: 'conversations.status.waiting_for_listing_author_to_accept_request', value: "Esperando a que %{listing_author_name} acepte la solicitud. En tal caso, se cargará el importe en tu tarjeta y podrás coordinar la recogida a través del chat. Si tu solicitud es rechazada no se efectuará ningún cargo en tu tarjeta.")
    translate(locale: 'ca', key: 'conversations.status.waiting_for_listing_author_to_accept_request', value: "Esperant que %{listing_author_name} accepti la sol·licitud. En tal cas, es carregarà l'import en la teva targeta i podràs coordinar la recollida a través del xat. Si la teva sol·licitud és rebutjada no s'efectuarà cap càrrec en la teva targeta.")


  end

  def translate(locale:, key:, value:)
    attrs = { locale: locale, translation: value }
    TranslationServiceHelper.translation_hashes_to_tr_key!([attrs], COMMUNITY_ID, key)
  end
end
