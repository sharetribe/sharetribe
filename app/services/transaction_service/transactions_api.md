# conversations/v1/

## POST /:conversation\_id/messages/

Example request body:

```ruby
{
  content: "Hi! I'd like to buy your bike.",
  sender_id: "5678dcba"
}
```

# transactions/v1/

## GET /can_start_transaction

Example request body:

```ruby
{ transaction:
  { payment_gateway: :none, # :paypal
  , community_id: 501
  , listing_author_id: "1234abcd"
  }
}
```

Response:

```ruby
{ result: true / false
}
```

## POST /create

Example request body:

```ruby
{ transaction:
  { payment_process: :none # :preauthorize
  , payment_gateway: :none, # :paypal
  , community_id: 501
  , starter_id: "5678dcba"
  , listing_id: 1234
  , listing_title: "Old city-bike"
  , listing_price: Money.new(50, "USD")
  , listing_author_id: "1234abcd"
  , listing_quantity: 1
  }

# If booking is used
# Note: end_on is included, i.e. 28.10. - 28.10. is a 1 day booking
, booking_fields:
  { start_on: <Date>
  , end_on: <Date>
  }

, gateway_fields: # Only for :paypal
  { success_url: "http://bikes.sharetribe.com/paypal_service/checkout_orders/success"
  , cancel_url: "http://bikes.sharetribe.com/paypal_service/checkout_orders/cancel?listing_id=1234"
  , merchant_brand_logo_url: "https://sharetribe.s3.amazonaws.com/images/communities/wide_logos/123/paypal/Marketplace_Logo.png"
  }
}
```

Response:

```ruby
{ transaction:
  { id: 1234
  , conversation_id: 3344,
  , payment_process: :none # or :preauthorize
  , payment_gateway: :paypal
  , community_id: 501
  , starter_id: "5678dcba"
  , listing_id: 1234
  , listing_title: "Old city-bike"
  , listing_price: Money.new(50, "USD")
  , listing_author_id: "1234abcd"
  , listing_quantity: 1
  , automatic_confirmation_after_days: 7
  , created_at: <Time>
  , updated_at: <Time>
  , last_transition_at: <Time>
  , current_state: :free       # or :initiated for Paypal
  }

# If booking is used
# Note: end_on is included, i.e. 28.10. - 28.10. is a 1 day booking
, booking_fields:
  { start_on: <Date>
  , end_on: <Date>
  }

  # PayPal
, gateway_fields:
  { redirect_url: "https://paypal.com/token?EJAHGOSKLGAHSG"
  }
}
```

## POST /:transaction_id/reject

Request: Empty

Response:

```ruby
{ transaction:
  { id: 1234
  , conversation_id: 3344,
  , payment_process: :preauthorize
  , payment_gateway: :paypal
  , community_id: 501
  , starter_id: "5678dcba"
  , listing_id: 1234
  , listing_title: "Old city-bike"
  , listing_price: Money.new(50, "USD")
  , listing_author_id: "1234abcd"
  , listing_quantity: 1
  , automatic_confirmation_after_days: 7
  , created_at: <Time>
  , updated_at: <Time>
  , last_transition_at: <Time>
  , current_state: :rejected
  , payment_total: Money.new(50, "USD")
  }

# If booking is used
# Note: end_on is included, i.e. 28.10. - 28.10. is a 1 day booking
, booking_fields:
  { start_on: <Date>
  , end_on: <Date>
  }
}
```

## POST /:transaction\_id/complete\_preauthorization

Only for **preauthorize** and **paypal**

Request: Empty

Response:

```ruby
{ transaction:
  { id: 1234
  , conversation_id: 3344,
  , payment_process: :preauthorize
  , payment_gateway: :paypal
  , community_id: 501
  , starter_id: "5678dcba"
  , listing_id: 1234
  , listing_title: "Old city-bike"
  , listing_price: Money.new(50, "USD")
  , listing_author_id: "1234abcd"
  , listing_quantity: 1
  , automatic_confirmation_after_days: 7
  , created_at: <Time>
  , updated_at: <Time>
  , last_transition_at: <Time>
  , current_state: :rejected
  , payment_total: Money.new(50, "USD")
  }

# If booking is used
# Note: end_on is included, i.e. 28.10. - 28.10. is a 1 day booking
, booking_fields:
  { start_on: <Date>
  , end_on: <Date>
  }

  # PayPal
, gateway_fields:
  { pending_reason: :multicurrency
  }

}
```

## POST /:transaction_id/complete

Request: Empty

Response:

```ruby
{ transaction:
  { id: 1234
  , conversation_id: 3344,
  , payment_process: :preauthorize
  , payment_gateway: :paypal
  , community_id: 501
  , starter_id: "5678dcba"
  , listing_id: 1234
  , listing_title: "Old city-bike"
  , listing_price: Money.new(50, "USD")
  , listing_author_id: "1234abcd"
  , listing_quantity: 1
  , automatic_confirmation_after_days: 7
  , created_at: <Time>
  , updated_at: <Time>
  , last_transition_at: <Time>
  , current_state: :completed
  , payment_total: Money.new(50, "USD")
  }

# If booking is used
# Note: end_on is included, i.e. 28.10. - 28.10. is a 1 day booking
, booking_fields:
  { start_on: <Date>
  , end_on: <Date>
  }
}
```

## POST /:transaction_id/cancel

Request: Empty

Response:

```ruby
{ transaction:
  { id: 1234
  , conversation_id: 3344,
  , payment_process: :preauthorize
  , payment_gateway: :paypal
  , community_id: 501
  , starter_id: "5678dcba"
  , listing_id: 1234
  , listing_title: "Old city-bike"
  , listing_price: Money.new(50, "USD")
  , listing_author_id: "1234abcd"
  , listing_quantity: 1
  , automatic_confirmation_after_days: 7
  , created_at: <Time>
  , updated_at: <Time>
  , last_transition_at: <Time>
  , current_state: :canceled
  , payment_total: Money.new(50, "USD")
  }

# If booking is used
# Note: end_on is included, i.e. 28.10. - 28.10. is a 1 day booking
, booking_fields:
  { start_on: <Date>
  , end_on: <Date>
  }
}
```
