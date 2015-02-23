## GET /translations/:community_id/

Scenario 1 - empty body:

Request no body

Response 200 OK, body:

```ruby
[ { translation_key: "dhfgh45tg75t3"
  , locale: "en-US"
  , translation: "Welcome"
  }
, { translation_key: "dhfgh45tg75t3"
  , locale: "fi-FI"
  , translation: "Tervetuloa"
  }
, { translation_key: "drt456rtfy545"
  , locale: "en-US"
  , translation: "Buy"
  }
, { translation_key: "drt456rtfy545"
  , locale: "fi-FI"
  , translation: "Osta"
  }
]
```

Scenario 2 - body contains 'translation_key' and optional 'locale':

Request body:
```ruby
[ { translation_key: "dhfgh45tg75t3"
  , locale: "en-US" // optional
  }
]
```

Response 200 OK, array of translations in body:

```ruby
[ { translation_key: "dhfgh45tg75t3"
  , locale: "en-US"
  , translation: "Welcome"
  }
]
```


## POST /translations/:community_id/

Scenario 1 - empty body:

Request no body

Response 400 Bad Request, body:
```ruby
{ error_message: "You must specify an array of locale & translation pairs in your request. e.g. '[{locale: "en-US", translation: "hello"}, {locale: "fi-FI", translation: "Moi"}]'
}
```

Scenario 2 - array of locale & translation pairs:

Request body:
```ruby
[ { locale: "en-US"
  , translation: "Welcome"
  }
, { locale: "fi-FI"
  , translation: "Tervetuloa"
  }
]
```

Response 201 Created, array of created translations in body:
```ruby
[ { translation_key: "dfnv7858vfjgk" // random hash string to be used when fetching a translation
  , locale: "en-US"
  , translation: "Welcome"
  }
, { translation_key: "dfnv7858vfjgk"
  , locale: "fi-FI"
  , translation: "Tervetuloa"
  }
]
```

## PUT /translations/:community_id/

Scenario 1 - empty body:

Request no body

Response 400 Bad Request, body:
```ruby
{ error_message: "You must specify an array of translation_key, locale & translation triples in your request. e.g. '[{translation_key: "dfnv7858vfjgk", locale: "en-US", translation: "hello"}, {translation_key: "dfnv7858vfjgk", locale: "fi-FI", translation: "Moi"}]'
}
```

Scenario 2 - array of translation_key, locale & translation:

Request body:
```ruby
[ { translation_key: "dfnv7858vfjgk"
  , locale: "en-US"
  , translation: "Welcome!"
  }
, { translation_key: "dfnv7858vfjgk"
  , locale: "fi-FI"
  , translation: "Tervetuloa!"
  }
]
```

Response 200 OK, updated translations in body:

```ruby
[ { translation_key: "dfnv7858vfjgk"
  , locale: "en-US"
  , translation: "Welcome!"
  }
, { translation_key: "dfnv7858vfjgk"
  , locale: "fi-FI"
  , translation: "Tervetuloa!"
  }
]
```


## DELETE /translations/:community_id/

Scenario 1 - empty body:

Request no body

Response 400 Bad Request, body:
```ruby
{ error_message: "You must specify an array of translation_key objects. e.g. '[{translation_key: "dfnv7858vfjgk"}, {translation_key: "dfnv7858vfjgk"}]'
}
```

Scenario 2 - array of translation_keys:

Request body:
```ruby
[ { translation_key: "dfnv7858vfjgk"
  }
]
```
Response 200 OK, deleted translations in body:

```ruby
[ { translation_key: "dfnv7858vfjgk"
  , locale: "en-US"
  , translation: "Welcome!"
  }
, { translation_key: "dfnv7858vfjgk"
  , locale: "fi-FI"
  , translation: "Tervetuloa!"
  }
]
```
