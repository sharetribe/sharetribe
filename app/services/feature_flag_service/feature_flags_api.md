# feature_flags/v1/

## GET /?community_id=123&person_id=456

Query params:

 - `community_id`: mandatory, for searching community-specific features
 - `person_id`: mandatory, for searching person-specific features

Request body: empty

Response body:

```ruby
{ community_id: 123
, person_id: 456
, features:
  [ :topbar_v1
  , :new_login
  ]
}
```

## GET /community/?community_id=123

Query params:

 - `community_id`: mandatory, for searching community-specific features

Request body: empty

Response body:

```ruby
{ community_id: 123
, features:
  [ :topbar_v1
  ]
}
```

## GET /person/?person_id=456

Query params:

 - `person_id`: mandatory, for searching person-specific features

Request body: empty

Response body:

```ruby
{ person_id: 456
, features:
  [ :new_login
  ]
}
```


## POST /?community_id=123&person_id=456

Query params:

 - `community_id`: mandatory
 - `person_id`: optional (if `person_id` is provided, operation tagets user-specific feature flags)

Request body:

```ruby
[ :some_feature
, :some_other_feature
]
```

Response body (person_id not provided):

```ruby
{ community_id: 123
, features:
  [ :topbar_v1
  , :some_feature
  , :some_other_feature
  ]
}
```

Response body (person_id provided):

```ruby
{ person_id: 456
, features:
  [ :new_login
  , :some_feature
  , :some_other_feature
  ]
}
```

## DELETE /?community_id=123&person_id=456

Query params:

 - `community_id`: mandatory
 - `person_id`: optional (if `person_id` is provided, operation tagets user-specific feature flags)

Request body:

```ruby
[ :topbar_v1
, :some_feature
]
```

Response body (person_id not provided):

```ruby
{ community_id: 123
, features:
  [ :new_login
  , :some_other_feature
  ]
}
```

Response body (person_id not provided):

```ruby
{ person_id: 456
, features:
  [ :new_login
  , :some_other_feature
  ]
}
```
