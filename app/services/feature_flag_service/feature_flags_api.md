
# feature_flags/v1/

## GET /:community_id

Request body: empty

Response body:

```ruby
{ community_id: 123
, features: 
  [ :topbar_v1
  , :new_login
  ]
}
```
## POST /:community_id

Request body:

```ruby
[ :some_feature
, :some_other_feature
]
```

Response body:

```ruby
{ community_id: 123
, features: 
  [ :topbar_v1
  , :new_login
  , :some_feature
  , :some_other_feature
  ]
}
```

## DELETE /:community_id

Request body:

```ruby
[ :topbar_v1
, :some_feature
]
```

Response body:

```ruby
{ community_id: 123
, features: 
  [ :new_login
  , :some_other_feature
  ]
}
```

## GET /enabled/:community_id/:feature

Request body: empty

Response body:

```ruby
{ enabled: true
}
```
