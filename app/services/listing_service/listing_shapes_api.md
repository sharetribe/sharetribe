# listing_shapes/v1/

## GET /:community_id/

Request: empty

Response:

```ruby
[
# Array of listing shapes, see the format below
]
```

## POST /:community_id

Request body:

```ruby
{ price_enabled: true
, transaction_process_id: 123
, name_tr_key: "listing_shape.1234.123"
, action_button_tr_key: "action_button.1234.123"
, units:
  [ { unit_type: :day }
  , { unit_type: :custom
    , label: "unit.1234.123"
    }
  ]
}
```

Response:

```ruby
{ id: 12345
, community_id: 9876
, price_enabled: true
, transaction_process_id: 123
, name_tr_key: "listing_shape.1234.123"
, action_button_tr_key: "action_button.1234.123"
, units:
  [ { unit_type: :day }
  , { unit_type: :custom
    , label: "unit.1234.123"
    }
  ]
}
```

## GET /:community_id/:listing_shape_id

Request: empty

Response:

```ruby
{ id: 12345
, community_id: 9876
, price_enabled: true
, transaction_process_id: 123
, name_tr_key: "listing_shape.1234.123"
, action_button_tr_key: "action_button.1234.123"
, units:
  [ { unit_type: :day }
  , { unit_type: :custom
    , label: "unit.1234.123"
    }
  ]
}
```

## DELETE /:community_id/:listing_shape_id

Request body: empty

Response:

```ruby
{ id: 12345
, community_id: 9876
, price_enabled: true
, transaction_process_id: 123
, name_tr_key: "listing_shape.1234.123"
, action_button_tr_key: "action_button.1234.123"
, units:
  [ { unit_type: :day }
  , { unit_type: :custom
    , label: "unit.1234.123"
    }
  ]
}
```
