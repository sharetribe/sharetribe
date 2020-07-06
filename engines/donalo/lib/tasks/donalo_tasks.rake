# rubocop:disable Metrics/LineLength
namespace :donalo do
  COMMUNITY_ID = 1

  desc "Override translations with Donalo's custom ones"
  task override_translations: :environment do
    translate(locale: 'es', key: 'listings.listing_actions.marketplace_fees_may_apply', value: "%{service_name} aplica una cuota de servicio por transacción que contribuye a mantener la plataforma")
    translate(locale: 'ca', key: 'listings.listing_actions.marketplace_fees_may_apply', value: "%{service_name} aplica una quota de servei per transacció que contribueix a mantenir la plataforma")

    translate(locale: 'es', key: 'settings.profile.location_description', value: "Esta ubicación debe ser dónde se encuentra el producto y dónde el receptor del mismo irá a buscarlo. Puedes dar tu ubicación exacta o indicar sólo tu código postal.")
    translate(locale: 'ca', key: 'settings.profile.location_description', value: "Aquesta ubicació ha de ser on es troba el producte i on el receptor de la mateixa anirà a buscar-lo. Pots donar la teva ubicació exacta o indicar només el teu codi postal.")

    translate(locale: 'es', key: 'settings.notifications.email_about_new_payments', value: "...recibo una nueva solicitud")
    translate(locale: 'ca', key: 'settings.notifications.email_about_new_payments', value: "...rebo una nova sol·licitud")

    translate(locale: 'es', key: 'conversations.status.waiting_for_listing_author_to_accept_request', value: "Esperando a que %{listing_author_name} acepte la solicitud. En tal caso, se cargará el importe en tu tarjeta y podrás coordinar la recogida a través del chat. Si tu solicitud es rechazada no se efectuará ningún cargo en tu tarjeta.")
    translate(locale: 'ca', key: 'conversations.status.waiting_for_listing_author_to_accept_request', value: "Esperant que %{listing_author_name} accepti la sol·licitud. En tal cas, es carregarà l'import en la teva targeta i podràs coordinar la recollida a través del xat. Si la teva sol·licitud és rebutjada no s'efectuarà cap càrrec en la teva targeta.")

    translate(locale: 'es', key: 'conversations.status.request_preauthorized', value: "Solicitud de producto pendiente de aprobar.")
    translate(locale: 'ca', key: 'conversations.status.request_preauthorized', value: "Sol·licitud de producte pendent d'aprovar.")

    translate(locale: 'es', key: 'conversations.status.offer_paid', value: " ")
    translate(locale: 'ca', key: 'conversations.status.offer_paid', value: " ")

    translate(locale: 'es', key: 'conversations.status.waiting_for_current_user_to_deliver_listing', value: "Has adjudicado el producto %{listing_title}. Por favor, coordina la recogida del producto a través del chat.")
    translate(locale: 'ca', key: 'conversations.status.waiting_for_current_user_to_deliver_listing', value: "Has adjudicat el producte %{listing_title}. Si us plau, coordina la recollida del producte a través del xat.")

    translate(locale: 'es', key: 'conversations.status.waiting_confirmation_from_you', value: "Tu solicitud ha sido aceptada. Coordina la recogida por el chat")
    translate(locale: 'ca', key: 'conversations.status.waiting_confirmation_from_you', value: "La teva sol·licitud ha estat acceptada. Coordina la recollida pel xat")

    translate(locale: 'es', key: 'conversations.status.stripe.waiting_confirmation_from_requester', value: "Esperando a que %{requester_name} marque la orden como completada.")
    translate(locale: 'ca', key: 'conversations.status.stripe.waiting_confirmation_from_requester', value: "Esperant que %{requester_name} marqui l'ordre com completada.")

    translate(locale: 'es', key: 'conversations.status.waiting_for_listing_author_to_deliver_listing', value: "Tu solicitud de producto ha sido aceptada. Por favor, indica el día y la hora en la que podrás ir a recoger el producto a través del chat. Una vez tengas el producto, por favor, vuelve a esta pantalla y completa la transacción para comunicarnos que ya has recogido el producto.<br/>Si por cualquier motivo, no has podido recibir el producto, clica la opción \"Hubo un incidente\" y desde el equipo Donalo se pondrá en contacto contigo.")
    translate(locale: 'ca', key: 'conversations.status.waiting_for_listing_author_to_deliver_listing', value: "La teva sol·licitud de producte ha estat acceptada. Si us plau, indica el dia i l'hora en la qual podràs anar a recollir el producte a través del xat. Una vegada tinguis el producte, si us plau, torna a aquesta pantalla i completa la transacció per a comunicar-nos que ja has recollit el producte.<br/>Si per qualsevol motiu, no has pogut rebre el producte, clica l'opció \"Obrir incidència\" i des de l'equip Donalo es posarà en contacte amb tu.")

    translate(locale: 'es', key: 'conversations.message.payment_preauthorized_wo_sum', value: "Solicitud de producto pendiente de aprobar.")
    translate(locale: 'ca', key: 'conversations.message.payment_preauthorized_wo_sum', value: "Sol·licitud de producte pendent d'aprovar.")

    translate(locale: 'es', key: 'conversations.message.stripe.confirmed_request', value: "Marcó la orden como completada.")
    translate(locale: 'ca', key: 'conversations.message.stripe.confirmed_request', value: "Ha marcat l'ordre com completada.")

    translate(locale: 'es', key: 'conversations.message.payment_has_now_been_transferred', value: "Marcó la orden como completada.")
    translate(locale: 'ca', key: 'conversations.message.payment_has_now_been_transferred', value: "Ha marcat l'ordre com completada.")

    translate(locale: 'es', key: 'conversations.message.received_payment_wo_sum', value: "Esperando a que propongas un día y hora de cuándo pasarás a recoger el producto.")
    translate(locale: 'ca', key: 'conversations.message.received_payment_wo_sum', value: "Esperant que proposis un dia i hora de quan passaràs a recollir el producte.")

    translate(locale: 'es', key: 'conversations.message.stripe.held_payment_wo_sum', value: "Aceptó la solicitud.")
    translate(locale: 'ca', key: 'conversations.message.stripe.held_payment_wo_sum', value: "S'ha acceptat a sol·licitud")

    translate(locale: 'es', key: 'conversations.message.canceled_the_order', value: "Abrió una incidència. El equipo de %{service_name} ha sido notificado.")
    translate(locale: 'ca', key: 'conversations.message.canceled_the_order', value: "Ha obert una incidència. L'equip de %{service_name} ha estat notificat.")

    translate(locale: 'es', key: 'conversations.message.dismissed_the_cancellation', value: "Descartó la incidència.")
    translate(locale: 'ca', key: 'conversations.message.dismissed_the_cancellation', value: "S'ha descartat la incidència.")

    translate(locale: 'es', key: 'conversations.message.payment_has_now_been_transferred', value: "Se ha resuelto, cualquier duda contacta con donalo.")
    translate(locale: 'ca', key: 'conversations.message.payment_has_now_been_transferred', value: "S'ha resolt, qualsevol dubte contacta amb donalo.")

    translate(locale: 'es', key: 'conversations.status_link.confirm', value: "He recibido bien el producto")
    translate(locale: 'ca', key: 'conversations.status_link.confirm', value: "He rebut bé el producte")

    translate(locale: 'es', key: 'conversations.status_link.cancel', value: "Hubo un incidente")
    translate(locale: 'ca', key: 'conversations.status_link.cancel', value: "Obrir incidència")

    translate(locale: 'es', key: 'conversations.confirm.confirm_description', value: "Recuerda que solo debes completar esta pantalla después de haber recogido el producto. Si no es así, ignora esta pantalla.")
    translate(locale: 'ca', key: 'conversations.confirm.confirm_description', value: "Recorda que només has de completar aquesta pantalla després d'haver recollit el producte. Si no és així, ignora aquesta pantalla.")

    translate(locale: 'es', key: 'conversations.confirm.cancel_description_team', value: "En caso de que haya surgido cualquier incidencia referente a la recogida del producto por favor marque la casilla \"Hubo un incidente\" y el equipo Donalo se pondrá en contacto contigo.")
    translate(locale: 'ca', key: 'conversations.confirm.cancel_description_team', value: "En cas que hagi sorgit qualsevol incidència referent a la recollida del producte si us plau marqui la casella \"Obrir incidència\" i l'equip Donalo es posarà en contacte amb tu.")

    translate(locale: 'es', key: 'conversations.confirm.confirm', value: "He recibido bien el producto")
    translate(locale: 'ca', key: 'conversations.confirm.confirm', value: "He rebut bé el producte")

    translate(locale: 'es', key: 'conversations.confirm.cancel', value: "Hubo un incidente")
    translate(locale: 'ca', key: 'conversations.confirm.cancel', value: "Obrir incidència")

    translate(locale: 'es', key: 'conversations.message.rejected_request', value: "rechazó la solicitud")
    translate(locale: 'es', key: 'conversations.message.rejected_request', value: "ha rebutjat la sol·licitud")

    translate(locale: 'es', key: 'conversations.accept.total_label', value: "Total (IVA incluido):")
    translate(locale: 'ca', key: 'conversations.accept.total_label', value: "Total (IVA inclòs):")

    translate(locale: 'es', key: 'transactions.total', value: "Total (IVA incluido):")
    translate(locale: 'ca', key: 'transactions.total', value: "Total (IVA inclòs):")

    translate(locale: 'es', key: 'transactions.total_to_pay', value: "Pago total (IVA incluido):")
    translate(locale: 'ca', key: 'transactions.total_to_pay', value: "Pagament total (IVA inclòs):")

    translate(locale: 'es', key: 'emails.confirm_reminder.you_have_not_yet_confirmed_or_canceled_request', value: "Aún no has completado la solicitud %{request_link}.  Si la solicitud se completó y ya tienes el producto en tu posesión por favor marca la opción 'he recibido el producto' para confirmarlo. Después de eso podrás dar una valoración a %{other_party_given_name}.")
    translate(locale: 'ca', key: 'emails.confirm_reminder.you_have_not_yet_confirmed_or_canceled_request', value: "Encara no has completat la sol·licitud %{request_link}. Si la sol·licitud es va completar i ja tens el producte a la teva possessió si us plau marca l'opció 'he rebut el producte' per confirmar-ho. Després d'això podràs donar una valoració a %{other_party_given_name}.")

    translate(locale: 'es', key: 'emails.transaction_confirmed.request_marked_as_canceled', value: "Hubo una incidencia")
    translate(locale: 'ca', key: 'emails.transaction_confirmed.request_marked_as_canceled', value: "Hi ha hagut una incidència")

    translate(locale: 'es', key: 'emails.confirm_reminder.cancel_it_link_text', value: "abrir una incidencia")
    translate(locale: 'ca', key: 'emails.confirm_reminder.cancel_it_link_text', value: "obrir una incidència")

    translate(locale: 'es', key: 'emails.confirm_reminder.automatic_confirmation', value: "Si no confirmas la solicitud o abres una indencia en %{days_to_automatic_confirmation} días después de que la solicitud haya sido aceptada, la marcaremos como completada automáticamente.")
    translate(locale: 'ca', key: 'emails.confirm_reminder.automatic_confirmation', value: "Si no confirmes la sol·licitud o obres una indencia en %{days_to_automatic_confirmation} dies després que la sol·licitud hagi estat acceptada, la marcarem com completada automàticament.")

    translate(locale: 'es', key: 'emails.transaction_confirmed.has_marked_request_as_canceled', value: "%{other_party_full_name} abrió una incidència para '%{request}'. Aún así puedes dar una valoración a %{other_party_given_name}.")
    translate(locale: 'ca', key: 'emails.transaction_confirmed.has_marked_request_as_canceled', value: "%{other_party_full_name} va obrir una incidència per a '%{request}'. Tot i així pots donar una valoració a %{other_party_given_name}.")

    translate(locale: 'es', key: 'emails.conversation_status_changed.remember_to_confirm', value: "Cuando la transacción sea completada, recuerda marcarla como completada. Si la transacción no es completada, dispones de %{days_to_automatic_confirmation} días para abrir una indencia o será marcada como completada automáticamente.")
    translate(locale: 'ca', key: 'emails.conversation_status_changed.remember_to_confirm', value: "Quan la transacció sigui completada, recorda marcar-la com completada. Si la transacció no és completada, disposes de %{days_to_automatic_confirmation} dies per obrir una indencia o serà marcada com completada automàticament.")

    translate(locale: 'es', key: 'emails.new_payment.new_payment', value: "Has recibido una nueva solicitud")
    translate(locale: 'ca', key: 'emails.new_payment.new_payment', value: "Has rebut una nova sol·licitud")

    translate(locale: 'es', key: 'emails.new_payment.you_have_received_new_payment', value: "%{payer_full_name} te ha solicitado <b>%{listing_title}</b>.")
    translate(locale: 'ca', key: 'emails.new_payment.you_have_received_new_payment', value: "%{payer_full_name} t'ha sol·licitat <b>%{listing_title}</b>.")

    translate(locale: 'es', key: 'emails.transaction_preauthorized.subject', value: "%{requester} está interesado en %{listing_title} en %{service_name}")
    translate(locale: 'ca', key: 'emails.transaction_preauthorized.subject', value: "%{requester} està interessat en %{listing_title} a %{service_name}")

    translate(locale: 'es', key: 'emails.transaction_preauthorized.transaction_requested_by_user', value: "Buenas noticias! %{requester} está interesado en \"%{listing_title}\".")
    translate(locale: 'ca', key: 'emails.transaction_preauthorized.transaction_requested_by_user', value: "Bones notícies! %{requester} està interessat en \"%{listing_title}\".")

    translate(locale: 'es', key: 'emails.transaction_preauthorized.if_you_do_accept_stripe', value: "Si aceptas la solicitud dentro de este periodo, la solicitud será completada.")
    translate(locale: 'ca', key: 'emails.transaction_preauthorized.if_you_do_accept_stripe', value: "Si acceptes la sol·licitud dins d'aquest període, la sol·licitud serà completada.")

    translate(locale: 'es', key: 'emails.transaction_preauthorized.if_you_do_not_accept', value: "Si rechazas la transacción o no aceptas la oferta durante este tiempo, la transacción se cancelará automáticamente.")
    translate(locale: 'ca', key: 'emails.transaction_preauthorized.if_you_do_not_accept', value: "Si rebutges la transacció o no acceptes l'oferta durant aquest temps, la transacció es cancel·larà automàticament.")

    translate(locale: 'es', key: 'emails.transaction_preauthorized_reminder.remember_to_accept', value: "Recuerda aceptar la solicitud de %{requester} sobre tu anuncio \"%{listing_title}\".")
    translate(locale: 'ca', key: 'emails.transaction_preauthorized_reminder.remember_to_accept', value: "Recorda acceptar la sol·licitud de %{requester} sobre el teu anunci \"%{listing_title}\".")

    translate(locale: 'es', key: 'emails.transaction_preauthorized_reminder.one_day_left', value: "Si no aceptas la solicitud en 1 día, la solicitud se rechazará automáticamente.")
    translate(locale: 'ca', key: 'emails.transaction_preauthorized_reminder.one_day_left', value: "Si no acceptes la sol·licitud en 1 dia, la sol·licitud es rebutjarà automàticament.")

    translate(locale: 'es', key: 'emails.transaction_disputed.subject', value: "Ha habido una inciencia en el pedido - El equipo de %{service_name} está revisando la situación")
    translate(locale: 'ca', key: 'emails.transaction_disputed.subject', value: "Hi ha hagut una inciencia en la comanda - L'equip de %{service_name} està revisant la situació")

    translate(locale: 'es', key: 'emails.transaction_disputed.subject_admin', value: "Una transacción ha sido marcada con indencia, debes decidir que pasa a continuación")
    translate(locale: 'ca', key: 'emails.transaction_disputed.subject_admin', value: "Una transacció ha estat marcada amb indencia, has de decidir que passa a continuació")

    translate(locale: 'es', key: 'emails.transaction_disputed.the_order_has_been_canceled', value: "Se ha abierto una incidencia en la %{transaction_link}.")
    translate(locale: 'ca', key: 'emails.transaction_disputed.the_order_has_been_canceled', value: "S'ha obert una incidència a la %{transaction_link}.")

    translate(locale: 'es', key: 'emails.transaction_disputed.the_order_between_buyer_and_seller_has_been_canceled', value: "en la %{transaction_link} entre %{buyer} y %{seller} se ha reportado una incidencia.")
    translate(locale: 'ca', key: 'emails.transaction_disputed.the_order_between_buyer_and_seller_has_been_canceled', value: "a la %{transaction_link} entre %{buyer} i %{seller} s'ha reportat una incidència.")

    translate(locale: 'es', key: 'emails.transaction_disputed.you_must_now_decide', value: "Debes decidir si un reembolso es válido o no. Si un reembolso no es valido, puede descartar la incidencia. Puedes %{learn_more_link}.")
    translate(locale: 'ca', key: 'emails.transaction_disputed.you_must_now_decide', value: "Has de decidir si un reemborsament és vàlid o no. Si un reemborsament no és vàlid, pot descartar la incidència. Pots %{learn_more_link}.")

    translate(locale: 'es', key: 'emails.transaction_refunded.subject', value: "La orden has sido marcada como reembolsada. El equipo de %{service_name} ha aprobado la solicitud de %{buyer}")
    translate(locale: 'ca', key: 'emails.transaction_refunded.subject', value: "L'ordre has estat marcada com a reemborsada. L'equip de %{service_name} ha aprovat la sol·licitud de %{buyer}")

    translate(locale: 'es', key: 'emails.transaction_refunded.marketplace_team_has_approved_the_cancellation', value: "El equipo de %{service_name} ha validado la incidencia de %{transaction_link} y ha marcado el pago como reembolsado.")
    translate(locale: 'ca', key: 'emails.transaction_refunded.marketplace_team_has_approved_the_cancellation', value: "l'equip de %{service_name} ha validat la incidència de %{transaction_link} i ha marcat el pagament com reemborsat.")

    translate(locale: 'es', key: 'emails.transaction_cancellation_dismissed.subject', value: "Incidencia descartada - El equipo de %{service_name} ha resuelto la incidencia de %{buyer}")
    translate(locale: 'ca', key: 'emails.transaction_cancellation_dismissed.subject', value: "Incidència descartada - L'equip de %{service_name} ha resolt la incidència de %{buyer}")

    translate(locale: 'es', key: 'emails.transaction_cancellation_dismissed.marketplace_team_has_rejected_the_cancellation', value: "el equipo de %{service_name} ha resuelto la incidencia de %{transaction_link}.")
    translate(locale: 'ca', key: 'emails.transaction_cancellation_dismissed.marketplace_team_has_rejected_the_cancellation', value: "l'equip de %{service_name} ha resolt la incidència de %{transaction_link}.")

    translate(locale: 'es', key: 'emails.receipt_to_payer.stripe.you_have_made_new_payment', value: "Has sido beneficiario de <b>%{listing_title}</b>. Por favor, accede a la conversación para coordinar un día y hora de entrega del producto.")
    translate(locale: 'ca', key: 'emails.receipt_to_payer.stripe.you_have_made_new_payment', value: "Has estat beneficiari de <b>%{listing_title}</b>. Si us plau, accedeix a la conversa per coordinar un dia i hora d'entrega del producte.")

    translate(locale: 'es', key: 'emails.transaction_confirmed.stripe.has_marked_request_as_confirmed', value: "%{other_party_full_name} ha marcado la orden de '%{request}' como completada. Puedes ahora dejar una valoración a %{other_party_given_name}.")
    translate(locale: 'ca', key: 'emails.transaction_confirmed.stripe.has_marked_request_as_confirmed', value: "%{other_party_full_name} ha marcat l'ordre de '%{request}' com completada. Pots ara deixar una valoració a %{other_party_given_name}.")


  end

  def translate(locale:, key:, value:)
    attrs = { locale: locale, translation: value }
    TranslationServiceHelper.translation_hashes_to_tr_key!([attrs], COMMUNITY_ID, key)
  end
end
# rubocop:enable Metrics/LineLength
