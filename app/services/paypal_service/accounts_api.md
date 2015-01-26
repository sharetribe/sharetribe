
# paypal/v1/

## POST /accounts/request

Request body:

```ruby
{ community_id: 121212     # Mandatory
, person_id: "person_id_1" # Mandatory for personal account, ignored for community account
, callback: "https://alpha.sharetribe.com/account/verify"
}
```

Response 201 Created, body:

```ruby
{ community_id: 121212
, person_id: "person_id_1"
, redirect_url: "https://www.sandbox.paypal.com/webscr?cmd=_grant-permission&request_token=AAAAAAAbDq-HJDXerDtj"
, username_to: "dev+paypal_api1.sharetribe.com"
}
```

## POST /accounts/:community_id/:person_id/cancel?token=AAAAAAAbDq-HJDXerDtj

Empty body

Response 204 No Content


## POST /accounts/:community_id/:person_id/create?token=AAAAAAAbDq-HJDXerDtj

```ruby
{ verification_code: '123512321531145'
}
```

Response 201 Created, with PaypalAccount body

```ruby
{ person_id: "person_id_1"
, community_id: 121212
, paypal_email: "dev+paypal-user1@sharetribe.com"
, payer_id: "98ASDF723S"
, order_permission_state: :verified
}
```

## POST /accounts/:community_id/:person_id/billing_agreement/request?token=AAAAAAAbDq-HJDXerDtj

```ruby
{ description: "Marketplace X would like to charge transaction fee"
, success_url: "https://alpha.sharetribe.com/account/billing_agreement_success"
, cancel_url: "https://alpha.sharetribe.com/account/billing_agreement_cancel"
}
```

```ruby
{ redirect_url: "https://www.sandbox.paypal.com/webscr?cmd=_grant-permission&request_token=AAAAAAAbDq-HJDXerDtj" }
```

## POST /accounts/:community_id/:person_id/billing_agreement/create?token=AAAAAAAbDq-HJDXerDtj

Empty body

Errors:

- :billing\_agreement\_not\_accepted - User did not accept the billing agreement
- :wrong\_account - The payer id did not match

## DELETE /accounts/:community_id/:person_id/billing_agreement

Empty body

Empty response

## GET /accounts/:community_id(/:person_id?)

No request body

Response 200 OK, with PaypalAccount body

```ruby
{ type: :community
, community_id: 121212
, paypal_email: "dev+mpadmin1@sharetribe.com"
, payer_id: "2387SHSDJH82"
, order_permission_state: :verified
, billing_agreement_state: :not_requested      # :not_requested, :pending, :verified ?
}
```

