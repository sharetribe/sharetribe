
# paypal/v1/

## POST /accounts/request

Request body:

```ruby
{ community_id: 121212     # Mandatory
, person_id: "person_id_1" # Optional: Ignored for community account
, country: "us"
, callback: "https://alpha.sharetribe.com/account/verify"
}
```

Response 201 Created, body:

```ruby
{ community_id: 121212
, person_id: "person_id_1"
, redirect_url: "https://www.sandbox.paypal.com/webscr?cmd=_grant-permission&request_token=AAAAAAAbDq-HJDXerDtj"
}
```

## POST /accounts/create?community_id=1&person_id=asdfajasfdgnqwer&order_permission_request_token=AAAAAAAbDq-HJDXerDtj

Query params:

- `community_id`: mandatory
- `person_id`: optional (ignored for admin accounts)
- `order_permission_request_token`: mandatory

Request body:

```ruby
{ order_permission_verification_code: '123512321531145'
}
```

Response 201 Created, with PaypalAccount body

```ruby
{ person_id: "person_id_1"
, community_id: 121212
, active: true,
, state: :not_connected,
, paypal_email: "dev+paypal-user1@sharetribe.com"
, payer_id: "98ASDF723S"
, order_permission_state: :verified
, billing_agreement_state: :not_verified
}
```

## POST /accounts/billing_agreement/request?token=AAAAAAAbDq-HJDXerDtj

Query params:

- `community_id`: mandatory
- `person_id`: mandatory

Request body:

```ruby
{ description: "Marketplace X would like to charge transaction fee"
, success_url: "https://alpha.sharetribe.com/account/billing_agreement_success"
, cancel_url: "https://alpha.sharetribe.com/account/billing_agreement_cancel"
}
```

Response:

```ruby
{ redirect_url: "https://www.sandbox.paypal.com/webscr?cmd=_grant-permission&request_token=AAAAAAAbDq-HJDXerDtj" }
```

## POST /accounts/billing_agreement/create?community_id=1&person_id=asdfasdgasdfasdg&billing_agreement_request_token=AAAAAAAbDq-HJDXerDtj

Query params:

- `community_id`: mandatory
- `person_id`: mandatory
- `billing_agreement_request_token`: mandatory

Empty request body

Errors:

- `:billing_agreement_not_accepted`: User did not accept the billing agreement
- `:wrong_account`: The payer id did not match

Response body: PaypalAccount

```ruby
{ person_id: "person_id_1"
, community_id: 121212
, active: true,
, state: :verified,
, paypal_email: "dev+paypal-user1@sharetribe.com"
, payer_id: "98ASDF723S"
, order_permission_state: :verified
, billing_agreement_state: :verified
, billing_agreement_billing_agreement_id: "B-125123245326"
}
```

## DELETE /accounts/billing_agreement?community_id=1&person_id=asdfasdgasdfasdg

Query params:

- `community_id`: mandatory
- `person_id`: mandatory

Empty body

Empty response


## DELETE /accounts?community_id=1&person_id=asdfasdgasdfasdg

Query params:

- `community_id`: mandatory
- `person_id`: optional (ignored for admin account)

Empty body

Empty response

## GET /accounts?community_id=1&person_id=aasdfasdgawsdg

Query params:

- `community_id`: mandatory
- `person_id`: optional (ignored for admin account)

Request body: Empty

Response body: PaypalAccount

```ruby
{ person_id: "person_id_1"
, community_id: 121212
, active: true,
, state: :verified,
, paypal_email: "dev+paypal-user1@sharetribe.com"
, payer_id: "98ASDF723S"
, order_permission_state: :verified
, billing_agreement_state: :verified
, billing_agreement_billing_agreement_id: "B-125123245326"
}
```
