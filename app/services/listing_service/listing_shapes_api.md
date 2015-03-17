# listing_shapes/v1/

## GET /:community_id/

Request: empty

Response:

```ruby
[ { id: 123
  , name: TranslationKey.new("listing_shape.1234.123")
  }
, ...
]
```

## GET /:community_id/:listing_shape_id

Request: empty

Response:

```ruby
[ { id: 123
  , name: TranslationKey.new("listing_shape.1234.123")
  , ...
  , ...
  , custom_fields: [ ... ]
  , units:
    [ { unit\_type: "day"}
    , { unit\_type: "custom"
      , label: TransactionKey.new("unit.1234.123")
      }
    ]
  }
  ,

  ...

]
```
