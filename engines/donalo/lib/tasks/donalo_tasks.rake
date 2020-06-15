namespace :donalo do
  COMMUNITY_ID = 1

  desc "Override translations with Donalo's custom ones"
  task override_translations: :environment do
    translate(locale: 'es', key: 'listings.listing_actions.marketplace_fees_may_apply', value: "%{service_name} aplica una cuota de servicio por transacción que contribuye a mantener la plataforma")
    translate(locale: 'ca', key: 'listings.listing_actions.marketplace_fees_may_apply', value: "%{service_name} aplica una quota de servei per transacció que contribueix a mantenir la plataforma")

    translate(locale: 'es', key: 'conversations.status.waiting_for_listing_author_to_accept_request', value: "Esperando a que %{listing_author_name} acepte la solicitud. En tal caso, se cargará el importe en tu tarjeta y podrás coordinar la recogida a través del chat. Si tu solicitud es rechazada no se efectuará ningún cargo en tu tarjeta.")
    translate(locale: 'ca', key: 'conversations.status.waiting_for_listing_author_to_accept_request', value: "Esperant que %{listing_author_name} accepti la sol·licitud. En tal cas, es carregarà l'import en la teva targeta i podràs coordinar la recollida a través del xat. Si la teva sol·licitud és rebutjada no s'efectuarà cap càrrec en la teva targeta.")

    translate(locale: 'es', key: 'conversations.status.request_preauthorized', value: "Solicitud de producto pendiente de aprobar")
    translate(locale: 'ca', key: 'conversations.status.request_preauthorized', value: "Sol·licitud de producte pendent d'aprovar")

    translate(locale: 'es', key: 'conversations.status.waiting_confirmation_from_you', value: "Tu solicitud ha sido aceptada. Coordina la recogida por el chat")
    translate(locale: 'ca', key: 'conversations.status.waiting_confirmation_from_you', value: "La teva sol·licitud ha estat acceptada. Coordina la recollida pel xat")

    translate(locale: 'es', key: 'conversations.status.stripe.waiting_confirmation_from_requester', value: "Esperando a que %{requester_name} marque la orden como completada.")
    translate(locale: 'ca', key: 'conversations.status.stripe.waiting_confirmation_from_requester', value: "Esperant que %{requester_name} marqui l'ordre com completada.")

    translate(locale: 'es', key: 'conversations.status.waiting_for_listing_author_to_deliver_listing', value: "Tu solicitud de producto ha sido aceptada. Por favor, indica el día y la hora en la que podrás ir a recoger el producto a través del chat. Una vez tengas el producto, por favor, vuelve a esta pantalla y completa la transacción para comunicarnos que ya has recogido el producto.<br/>Si por cualquier motivo, no has podido recibir el producto, clica la opción \"Hubo un incidente\" y desde el equipo Donalo se pondrá en contacto contigo.")
    translate(locale: 'ca', key: 'conversations.status.waiting_for_listing_author_to_deliver_listing', value: "La teva sol·licitud de producte ha estat acceptada. Si us plau, indica el dia i l'hora en la qual podràs anar a recollir el producte a través del xat. Una vegada tinguis el producte, si us plau, torna a aquesta pantalla i completa la transacció per a comunicar-nos que ja has recollit el producte.<br/>Si per qualsevol motiu, no has pogut rebre el producte, clica l'opció \"Obrir incidència\" i des de l'equip Donalo es posarà en contacte amb tu.")

    translate(locale: 'es', key: 'conversations.message.payment_preauthorized_wo_sum', value: "Solicitud de producto pendiente de aprobar")
    translate(locale: 'ca', key: 'conversations.message.payment_preauthorized_wo_sum', value: "Sol·licitud de producte pendent d'aprovar")

    translate(locale: 'es', key: 'conversations.message.stripe.confirmed_request', value: "Marcó la orden como completada.")
    translate(locale: 'ca', key: 'conversations.message.stripe.confirmed_request', value: "Ha marcat l'ordre com completada.")

    translate(locale: 'es', key: 'conversations.message.payment_has_now_been_transferred', value: "Marcó la orden como completada.")
    translate(locale: 'ca', key: 'conversations.message.payment_has_now_been_transferred', value: "Ha marcat l'ordre com completada.")

    translate(locale: 'es', key: 'conversations.message.received_payment_wo_sum', value: "Esperando a que escribas a %{listing_author_name} un día y hora de cuándo pasarás a recoger el producto.")
    translate(locale: 'ca', key: 'conversations.message.received_payment_wo_sum', value: "Esperant que escribes a %{listing_author_name} un dia i hora de quan passaràs a recollir el producte.")

    translate(locale: 'es', key: 'conversations.status_link.confirm', value: "He recibido bien el producto")
    translate(locale: 'ca', key: 'conversations.status_link.confirm', value: "He rebut bé el producte")

    translate(locale: 'es', key: 'conversations.status_link.cancel', value: "Hubo un incidente")
    translate(locale: 'ca', key: 'conversations.status_link.cancel', value: "Obrir incidència")

    translate(locale: 'es', key: 'conversations.confirm.confirm_description', value: "Recuerda que solo debes completar esta pantalla después de haber recogido el producto. Si no es así, ignora esta pantalla.")
    translate(locale: 'ca', key: 'conversations.confirm.confirm_description', value: "Recorda que només has de completar aquesta pantalla després d'haver recollit el producte. Si no és així, ignora aquesta pantalla.")

    translate(locale: 'es', key: 'conversations.confirm.cancel_description_team', value: "En caso de que haya surgido cualquier incidencia referente a la recogida del producto por favor marque la casilla \"Hubo un incidente\" y el equipo Donalo se pondrá en contacto contigo.")
    translate(locale: 'ca', key: 'conversations.confirm.cancel_description_team', value: "En cas que hagi sorgit qualsevol incidència referent a la recollida del producte si us plau marqui la casella \"Obrir incidència\" i l'equip Donalo es posarà en contacte amb tu.")

  end

  def translate(locale:, key:, value:)
    attrs = { locale: locale, translation: value }
    TranslationServiceHelper.translation_hashes_to_tr_key!([attrs], COMMUNITY_ID, key)
  end
end
