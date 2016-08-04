# feature_flags/v1/

## GET /?community_id=123&person_id=456

Query params:

 - `community_id`: mandatory
 - `person_id`: optional (if `person_id` is provided, operation tagets user-specific feature flags)

Request body: empty

Response body (person_id not provided):

```ruby
{ community_id: 123
, features:
  [ :topbar_v1
  , :new_login
  ]
}
```

Response body (person_id provided):

```ruby
{ person_id: 456
, features:
  [ :topbar_v1
  , :new_login
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
  , :new_login
  , :some_feature
  , :some_other_feature
  ]
}
```

Response body (person_id provided):

```ruby
{ person_id: 456
, features:
  [ :topbar_v1
  , :new_login
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

## GET /enabled/?community_id=123&person_id=456

Query params:

 - `community_id`: mandatory
 - `person_id`: optional (if `person_id` is provided, operation tagets community and user-specific feature flags, otherwise just community-specific flags are taken into account)

Request body: empty

Response body:

```ruby
{ data: true }
```
