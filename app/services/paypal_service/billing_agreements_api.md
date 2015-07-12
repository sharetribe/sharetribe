## POST /billing_agreements/:community_id/:person_id/charge_commission

Request body CommissionInfo:

```ruby
{ transaction_id: 123456789
, commission_total: <Money>
, payment_name: "commission payment name"
, payment_desc: "commission payment desc"
}
```

Response 200 OK, Payment body:

```ruby
{ community_id: 121212
, transaction_id: 123456789
, payer_id: "6M39X6RCYVUD6"      # Paypal internal id, do we need to expose it?
, receiver_id: "URAPMR7WHFAWY"   # Paypal internal id, do we need to expose it?
, merchant_id: "merchant_id_1"   # External merchant user id, linked with the receiver_id
, payment_status: :completed
, pending_reason: nil
, order_id: "O-8VG2704956180171B"
, order_date: <Time>
, order_total: <Money>
, authorization_id: "0L584749FU2628910"
, authorization_date: <Time>
, authorization_expires_date: <Time>
, authorization_total: <Money>
, payment_id: "092834KH234J"
, payment_date: <Time>
, payment_total: <Money>
, fee_total: <Money>
, commission_payment_id: "08387GJK384"
, commission_payment_date: <Time>
, commission_status: :completed  # :not_charged, :completed, or :pending
, commissions_pending_reason     # :none, :multicurrency, etc
, commission_total: <Money>
, commission_fee_total: <Money>
}
```
