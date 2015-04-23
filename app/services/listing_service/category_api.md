
# categories/v1/

## GET /:community_id/

Request: empty

Response:

```ruby
{ id: 1234
, community_id: 9876
, parent_id: 23455
, sort_priority: 10
, name: "bikes"
, listing_shape_ids: [123, 234, 345, 456]
, translations: [ { locale: "en", name: "Bikes" } ]
, children:
  [ { id: 12346
    , community_id: 9876
    , parent_id: 1234
    , sort_priority: 1
    , name: "mountain-bikes"
    , listing_shape_ids: [123, 234, 345, 456]
    , translations: [ { locale: "en", name: "Mountain Bikes" } ]
    }
  , { id: 12347
    , community_id: 9876
    , parent_id: 1234
    , sort_priority: 2
    , name: "city-bikes"
    , listing_shape_ids: [123, 234, 345, 456]
    , translations: [ { locale: "en", name: "City Bikes" } ]
    }
  ]
}
```

## GET /:community_id/:category_id

Response:

```ruby
{ id: 12346
, community_id: 9876
, parent_id: 1234
, sort_priority: 1
, name: "moutain-bikes"
, listing_shape_ids: [123, 234, 345, 456]
, translations: [ { locale: "en", name: "Mountain Bikes" } ]
}
```

## POST /:community_id

Response:

```ruby
{ parent_id: 123 # optional
, sort_priority: 10
, translations: [ { locale: "en", name: "Bikes" } ]
}
```
