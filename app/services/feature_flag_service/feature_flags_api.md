
# feature_flags/v1/community

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

# feature_flags/v1/user

## GET /:user_id

Request body: empty

Response body:

```ruby
{ user_id: 123
, features: 
  [ :topbar_v1
  , :new_login
  ]
}
```

## POST /:user_id

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

## POST /

Request body:

```ruby
{ users: 
  [ "user_id_1"
  , "user_id_2"
  , "user_id_3"
  ]
, features:
  [ :some_feature
  , :some_other_feature
  ]
}
```

Response body:

```ruby
[ { user_id: "user_id_1"  
  , features: 
    [ :new_login
    , :some_feature
    , :some_other_feature
    ]
  }
, { user_id: "user_id_2"  
  , features: 
    [ :topbar_v1
    , :some_feature
    , :some_other_feature
    ]
  }
, { user_id: "user_id_3"  
  , features: 
    [ :some_feature
    , :some_other_feature
    ]
  }
]
```

## DELETE /:user_id

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

## DELETE /

Request body:

```ruby
{ user_ids: 
  [ "user_id_1"
  , "user_id_2"
  , "user_id_3"
  ]
, features:
  [ :some_feature
  , :some_other_feature
  ]
}
```

Response body:

```ruby
[ { user_id: "user_id_1"  
  , features: 
    [ :new_login
    ]
  }
, { user_id: "user_id_2"  
  , features: 
    [ :topbar_v1
    ]
  }
, { user_id: "user_id_3"  
  , features: [ ]
  }
]
```

## GET /enabled/:user_id/:feature

Request body: empty

Response body:

```ruby
{ enabled: true
}
```
