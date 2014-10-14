
# paypal/v1/

## POST /billing_agreements/request

Request body:

```js
{ community_id: 121212
, person_id: "person_id_1"
, description: "Permission to charge commissions."
, success: "https://alpha.sharetribe.com/billing_agreement/success"
, cancel: "https://alpha.sharetribe.com/billing_agreement/cancel"
}
```

Response 201 Created, body:

```js
{ community_id: 121212
, person_id: "person_id_1"
, token: "EC-3TH127556H844745T"
, redirect_url: "https://www.sandbox.paypal.com/webscr?cmd=_express-checkout&token=EC-3TH127556H844745T"
, username_to: "dev+paypal_api1.sharetribe.com"
}
```


## POST /billing_agreements/cancel?token=EC-3TH127556H844745T

Request body:

```js
{ community_id: 121212
, person_id: "person_id_1"
}
```

Response 204 No Content


## POST /billing_agreements/create?token=EC-3TH127556H844745T

Request body:

```js
{ community_id: 121212
, person_id: "person_id_1"
}
```

Response 201 Created, body:

```js
{ community_id: 121212
, person_id: "person_id_1"
, billing_agreement_state: :verified
, billing_agreement_id: "B-6LN09317DE8098150"
}
```


## GET /billing_agreements/:community_id/:person_id

Response 200 OK, body:

```js
{ community_id: 121212
, person_id: "person_id_1"
, billing_agreement_state: :verified // Could also be :pending, but :not_requested is returned as 404
, billing_agreement_id: "B-6LN09317DE8098150"
}
```

## POST /billing_agreements/:community_id/:person_id/charge

TODO
* How to link this to transaction?
* How to record it at paypal service, as another payment linked to same transaction? as additional fields in payment?

Request body:

```js
{ community_admin_id: "community_admin_1" // External person, community admin receiving the commissions, must match to existing paypal admin account
, commission_total: Money.new(120, "GBP")
}
```


Response 201, Body wut?
