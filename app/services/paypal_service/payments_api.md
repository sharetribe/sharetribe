
# paypal/v1/

## POST /payments/request

Example request body:

```js
{ transaction_id: 123456789           // External transaction id
, item_name: "A green lantern"
, item_quantity: 1
, item_price: Money.new(120, "GBP")
, merchant_id: "merchant_id_1"        // External user id, must match to an existing paypal account
, order_total: Money.new(120, "GBP")
, success: "http://alpha.sharetribe.com/transaction/create"
, cancel: "http://alpha.sharetribe.com/transactin/cancel"
}
```

Response 201 Created, with PaymentRequest body

Example response body:

```js
{ redirect_url: "https://www.sandbox.paypal.com/webscr?cmd=_express-checkout&token=EC-7XU83376C70426719&useraction=commit"
, token: "EC-7XU83376c70426719"
, transaction_id: 123456789
}
```

## POST /payments/request/cancel?token=EC-7XU83376C70426719

```js
{ transaction_id: 123456789 }
```

## POST /payments/create?token=EC-7XU83376C70426719

```js
{ transaction_id: 123456789 }
```

Response 201 Created, with Payment body

Example response body:

```js
{ transaction_id: 123456789
, payer_id: "6M39X6RCYVUD6"      // Paypal internal id, do we need to expose it?
, receiver_id: "URAPMR7WHFAWY"   // Paypal internal id, do we need to expose it?
, merchant_id: "merchant_id_1"   // External merchant user id, linked with the receiver_id
, payment_status: :pending
, pending_reason: :order
, order_id: "O-8VG2704956180171B"
, order_date: Time.new(...)
, order_total: Money.new(120, "GBP")
, authorization_id:
, authorization_date:
, authorization_expires_date:
, authorization_total:
, payment_id:
, payment_date:
, payment_total:
, fee_total:
}
```

## POST /payments/:transaction_id/authorize

Example request body:

```js
{ authorization_total: Money.new(120, "GBP") }
```

Response 200 OK, Payment body:

```js
{ transaction_id: 123456789
, payer_id: "6M39X6RCYVUD6"      // Paypal internal id, do we need to expose it?
, receiver_id: "URAPMR7WHFAWY"   // Paypal internal id, do we need to expose it?
, merchant_id: "merchant_id_1"   // External merchant user id, linked with the receiver_id
, payment_status: :pending
, pending_reason: :authorization
, order_id: "O-8VG2704956180171B"
, order_date: Time.new(...)
, order_total: Money.new(120, "GBP")
, authorization_id: "0L584749FU2628910"
, authorization_date: Time.new(...)
, authorization_expires_date: // We have only guesstimate at this point, should we return it even if it changes later?
, authorization_total: Money.new(120, "GBP")
, payment_id:
, payment_date:
, payment_total:
, fee_total:
}
```


## POST /payments/:transaction_id/full_capture

Example request body:

```js
{ payment_total: Money.new(120, "GBP") }
```

Response 200 OK, Payment body:

```js
{ transaction_id: 123456789
, payer_id: "6M39X6RCYVUD6"      // Paypal internal id, do we need to expose it?
, receiver_id: "URAPMR7WHFAWY"   // Paypal internal id, do we need to expose it?
, merchant_id: "merchant_id_1"   // External merchant user id, linked with the receiver_id
, payment_status: :completed
, pending_reason: null / nil
, order_id: "O-8VG2704956180171B"
, order_date: Time.new(...)
, order_total: Money.new(120, "GBP")
, authorization_id: "0L584749FU2628910"
, authorization_date: Time.new(...)
, authorization_expires_date: // We have only a guesstimate at this point, should we return it even if it changes later?
, authorization_total: Money.new(120, "GBP")
, payment_id: "092834KH234J"
, payment_date: Time.new(...)
, payment_total: Money.new(120, "GBP")
, fee_total: Money.new(48, "GBP")
}
```

## GET /payments/:transaction_id

Response 200 OK, Payment body (example as above)


## POST /payments/:transaction_id/void

Response 204 No Content


## POST /payments/:transaction_id/refund

Response 200 OK, Payment body

```js
{ transaction_id: 123456789
, payer_id: "6M39X6RCYVUD6"      // Paypal internal id, do we need to expose it?
, receiver_id: "URAPMR7WHFAWY"   // Paypal internal id, do we need to expose it?
, merchant_id: "merchant_id_1"   // External merchant user id, linked with the receiver_id
, payment_status: :refunded
, pending_reason: null / nil
, order_id: "O-8VG2704956180171B"
, order_date: Time.new(...)
, order_total: Money.new(120, "GBP") // ? - refunded_net_total?
, authorization_id: "0L584749FU2628910"
, authorization_date: Time.new(...)
, authorization_expires_date: // We have only a guesstimate at this point, should we return it even if it changes later?
, authorization_total: Money.new(120, "GBP")
, payment_id: "092834KH234J"
, payment_date: Time.new(...)
, payment_total: Money.new(120, "GBP")
, fee_total: Money.new(48, "GBP") // ? - refunded_fee_total
}
```

# Open questions / TODO

* All requests have header community_id so that it's enough to have unique transaction ids within a community? (future extension)
* No error scenarios here
