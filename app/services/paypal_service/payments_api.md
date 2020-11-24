
# paypal/v1/

## Common message types

All messages have the following structure. Body describes data contents.

Example success message:

```ruby
{ success: true
, data: <body>
}
```

Example error message:

```ruby
{ success: false
, error_msg: "Error message"
, data: <body>
}
```

## POST /payments/:community_id/request

Request body CreatePaymentRequest

Example request body:

```ruby
{ transaction_id: 123456789           # External transaction id
, item_name: "A green lantern"
, item_quantity: 1
, item_price: <Money>
, merchant_id: "merchant_id_1"        # External user id, must match to an existing paypal account
, order_total: <Money>
, success: "http://alpha.sharetribe.com/transaction/create"
, cancel: "http://alpha.sharetribe.com/transactin/cancel"
}
```

Response 201 Created, with PaymentRequest body

Example response body:

```ruby
{ redirect_url: "https://www.sandbox.paypal.com/webscr?cmd=_express-checkout&token=EC-7XU83376C70426719&useraction=commit"
, token: "EC-7XU83376c70426719"
, transaction_id: 123456789
}
```

## POST /payments/:community_id/request/cancel?token=EC-7XU83376C70426719

Response 204 No Content

## POST /payments/:community_id/create?token=EC-7XU83376C70426719

Example request body:

```ruby
{ authorization_total: <Money> }
```

Response 200 OK, Payment body:

```ruby
{ community_id: 10
, transaction_id: 123456789
, payer_id: "6M39X6RCYVUD6"      # Paypal internal id, do we need to expose it?
, receiver_id: "URAPMR7WHFAWY"   # Paypal internal id, do we need to expose it?
, merchant_id: "merchant_id_1"   # External merchant user id, linked with the receiver_id
, payment_status: :pending
, pending_reason: :authorization
, order_id: "O-8VG2704956180171B"
, order_date: <Time>
, order_total: <Money>
, authorization_id: "0L584749FU2628910"
, authorization_date: <Time>
, authorization_expires_date: <Time>
, authorization_total: <Money>
, commission_status: :not_charged
}
```

## POST /payments/:community_id/:transaction_id/full_capture

Request body PaymentInfo

Example request body:

```ruby
{ payment_total: <Money> }
```

Response 201 Created, Payment body:

```ruby
{ community_id: 10
, transaction_id: 123456789
, payer_id: "6M39X6RCYVUD6"      # Paypal internal id, do we need to expose it?
, receiver_id: "URAPMR7WHFAWY"   # Paypal internal id, do we need to expose it?
, merchant_id: "merchant_id_1"   # External merchant user id, linked with the receiver_id
, payment_status: :completed
, pending_reason: :none
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
, commission_status: :not_charged
}
```

Response 200 OK, Error body:

```ruby
{ community_id: 501,
  transaction_id: 999,
  paypal_error_code: 10486
, redirect_url: "https://www.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=EC-ABCDE12345"
}
```

## GET /payments/:community_id/:transaction_id

Response 200 OK, Payment body (example as above)


## POST /payments/:community_id/:transaction_id/void

Request body VoidingInfo

Example request body:

```ruby
{ note: "The reason why the transaction was voided." }
```

Response 200, voided payment body

```ruby
{ community_id: 10
, transaction_id: 123456789
, payer_id: "6M39X6RCYVUD6"      # Paypal internal id, do we need to expose it?
, receiver_id: "URAPMR7WHFAWY"   # Paypal internal id, do we need to expose it?
, merchant_id: "merchant_id_1"   # External merchant user id, linked with the receiver_id
, payment_status: :voided
, pending_reason: :none
, order_id: "O-8VG2704956180171B"
, order_date: <Time>
, order_total: <Money>
, authorization_id: "0L584749FU2628910"
, authorization_date: <Time>
, authorization_expires_date: <Time>
, authorization_total: <Money>
, payment_id:
, payment_date:
, payment_total:
, fee_total:
, commission_status: :not_charged
```

## POST /payments/:community_id/:transaction_id/refund

Request no body

Response 200 OK, Payment body

```ruby
{ community_id: 10
, transaction_id: 123456789
, payer_id: "6M39X6RCYVUD6"              # Paypal internal id, do we need to expose it?
, receiver_id: "URAPMR7WHFAWY"           # Paypal internal id, do we need to expose it?
, merchant_id: "merchant_id_1"           # External merchant user id, linked with the receiver_id
, payment_status: :refunded
, pending_reason: nil
, order_id: "O-8VG2704956180171B"
, order_date: <Time>
, order_total: <Money>                   # ? - refunded_net_total?
, authorization_id: "0L584749FU2628910"
, authorization_date: <Time>
, authorization_expires_date: <Time>
, authorization_total: <Money>
, payment_id: "092834KH234J"
, payment_date: <Time>
, payment_total: <Money>
, fee_total: <Money>                     # ? - refunded_fee_total
, commission_status: :not_charged
}
```

# Open questions / TODO

* All requests have header community_id so that it's enough to have unique transaction ids within a community? (future extension)
* No error scenarios here
