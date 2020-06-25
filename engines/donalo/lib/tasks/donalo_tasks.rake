# rubocop:disable Metrics/LineLength
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

    translate(locale: 'es', key: 'transactions.total', value: "Total (IVA incluido):")
    translate(locale: 'ca', key: 'transactions.total', value: "Total (IVA inclòs):")

    translate(locale: 'es', key: 'transactions.total_to_pay', value: "Pago total (IVA incluido):")
    translate(locale: 'ca', key: 'transactions.total_to_pay', value: "Pagament total (IVA inclòs):")

    translate(locale: 'es', key: 'conversations.confirm.confirm', value: "He recibido bien el producto")
    translate(locale: 'ca', key: 'conversations.confirm.confirm', value: "He rebut bé el producte")

    translate(locale: 'es', key: 'conversations.confirm.cancel', value: "Hubo un incidente")
    translate(locale: 'ca', key: 'conversations.confirm.cancel', value: "Obrir incidència")

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

    translate(locale: 'es', key: 'emails.new_payment.new_payment', value: "Has recibido un nuevo pago")

    translate(locale: 'es', key: 'emails.new_payment.price_per_unit_type', value: "Precio por %{unit_type}")

    translate(locale: 'es', key: 'emails.new_payment.quantity', value: "Cantidad:")

    translate(locale: 'es', key: 'emails.new_payment.you_have_received_new_payment', value: "%{payer_full_name} te ha pagado <b>%{payment_sum}<b> por <b>%{listing_title}</b>. Aquí está tu recibo.")

    translate(locale: 'es', key: 'emails.new_payment.stripe.you_have_received_new_payment', value: "La cantidad de <b>%{payment_sum}</b> ha sido pagada para <b>%{listing_title}</b> por %{payer_full_name}. El dinero esta siendo retenido por %{service_name} hasta que la orden sea marcada como completada. Aquí está tu recibo.")

    translate(locale: 'es', key: 'emails.transaction_preauthorized.subject', value: "%{requester} está interesado en %{listing_title} en %{service_name}")
    translate(locale: 'ca', key: 'emails.transaction_preauthorized.subject', value: "%{requester} està interessat en %{listing_title} a %{service_name}")

    translate(locale: 'es', key: 'emails.transaction_preauthorized.transaction_requested_by_user', value: "Buenas noticias! %{requester} está interesado en \"%{listing_title}\" y ya ha autorizado el pago por este anuncio.")

    translate(locale: 'es', key: 'emails.transaction_preauthorized.if_you_do_accept_stripe', value: "Si aceptas la solicitud dentro de este periodo, el pago será completado. Recibirás el dinero directamente en tu cuenta de banco después de que hayas completado %{listing_title} para %{requester}.")

    translate(locale: 'es', key: 'emails.transaction_preauthorized.if_you_do_not_accept', value: "Si rechazas la transacción o no aceptas la oferta durante este tiempo, la transacción se cancelará automáticamente, no se le cobrará a %{requester} y no recibirás el pago.")

    translate(locale: 'es', key: 'emails.transaction_preauthorized_reminder.remember_to_accept', value: "Recuerda aceptar la solicitud de %{requester} sobre tu anuncio \"%{listing_title}\". %{requester} ya ha pagado. Debes aceptar la solicitud para poder recibir el pago.")

    translate(locale: 'es', key: 'emails.transaction_preauthorized_reminder.one_day_left', value: "Si no aceptas la solicitud en 1 día, la solicitud se rechazará automáticamente y no recibirás ningún pago.")

    translate(locale: 'es', key: 'emails.transaction_disputed.subject', value: "Orden disputada - El equipo de %{service_name} está revisando la situación")

    translate(locale: 'es', key: 'emails.transaction_disputed.subject_admin', value: "Una transacción ha sido disputada, debes decidir que pasa a continuación")

    translate(locale: 'es', key: 'emails.transaction_disputed.the_order_has_been_canceled', value: "la %{transaction_link} ha sido disputada.")

    translate(locale: 'es', key: 'emails.transaction_disputed.the_order_between_buyer_and_seller_has_been_canceled', value: "la %{transaction_link} entre %{buyer} y %{seller} ha sido disputada.")

    translate(locale: 'es', key: 'emails.transaction_disputed.you_must_now_decide', value: "Debes decidir si un reembolso es válido o no. Si un reembolso no es valido, puede descartar la disputa. Puedes %{learn_more_link}.")

    translate(locale: 'es', key: 'emails.transaction_refunded.subject', value: "La orden has sido marcada como reembolsada. El equipo de %{service_name} ha aprobado la disputa de %{buyer}")

    translate(locale: 'es', key: 'emails.transaction_refunded.marketplace_team_has_approved_the_cancellation', value: "el equipo de %{service_name} ha aprovado la disputa de %{transaction_link} y ha marcado el pago como reembolsado.")

    translate(locale: 'es', key: 'emails.transaction_cancellation_dismissed.subject', value: "Disputa de la orden descartada - El equipo de %{service_name} ha rechazado la disputa de %{buyer}")

    translate(locale: 'es', key: 'emails.transaction_cancellation_dismissed.marketplace_team_has_rejected_the_cancellation', value: "el equipo de %{service_name} ha rechazado la disputa de %{transaction_link}.")




  end

  def translate(locale:, key:, value:)
    attrs = { locale: locale, translation: value }
    TranslationServiceHelper.translation_hashes_to_tr_key!([attrs], COMMUNITY_ID, key)
  end
end
# rubocop:enable Metrics/LineLength
