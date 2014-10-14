
# paypal/v1/

## POST /accounts/request

Request body:

```js
{ type: :personal          // or :community
, community_id: 121212     // Mandatory
, person_id: "person_id_1" // Mandatory for personal account, ignored for community account
, callback: "https://alpha.sharetribe.com/account/verify"
}
```

Response 201 OK, body:

```js
{ community_id: 121212
, person_id: "person_id_1"
, token: "AAAAAAAbDq-HJDXerDtj"
, redirect_url: "https://www.sandbox.paypal.com/webscr?cmd=_grant-permission&request_token=AAAAAAAbDq-HJDXerDtj"
, username_to: "dev+paypal_api1.sharetribe.com"
}
```

## POST /accounts/request/cancel?token=AAAAAAAbDq-HJDXerDtj

```js
{ community_id: 121212
, person_id: "person_id_1"
}
```

Response 204 No Content


## POST /accounts/create?token=AAAAAAAbDq-HJDXerDtj

```js
{ community_id: 121212
, person_id: "person_id_1"
}
```

Response 201 Created, with PaypalAccount body

```js
{ type: :personal
, person_id: "person_id_1"
, community_id: 121212
, paypal_email: "dev+paypal-user1@sharetribe.com"
, payer_id: "98ASDF723S"
, order_permission_state: :verified
}
```

## GET /accounts/:community_id(/:person_id?)

No request body

Reponse 200 OK, with PaypalAccount body

```js
{ type: :community
, community_id: 121212
, paypal_email: "dev+mpadmin1@sharetribe.com"
, payer_id: "2387SHSDJH82"
, order_permission_state: :verified
}
```

