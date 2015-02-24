## GET /translations/:community_id/

###Scenario 1 - empty body:
i.e. get all translations

Request no body

Response 200 OK, all translations for community in body:

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


###Scenario 2 - request body contains translation_keys and locale(s):
e.g. user goes to a page x

Request body:
```ruby
{ translation_keys: ["dhfgh45tg75t3", "dhfgh45tg75t4", "dhfgh45tg75t5", "dhfgh45tg75t6"]
, locales: ["en-US"]
}
```

Response 200 OK, array of asked translations in body:
```ruby
[ { translation_key: "dhfgh45tg75t3"
  , locale: "en-US"
  , translation: "Welcome"
  }
, { translation_key: "dhfgh45tg75t4"
  , locale: "en-US"
  , error: "TRANSLATION_KEY_MISSING"    // Translation key is missing.
  }
, { translation_key: "dhfgh45tg75t5"
  , locale: "en-US"
  , error: "TRANSLATION_LOCALE_MISSING" // Translation locale is missing
  , fallback:
    { translation_key: "dhfgh45tg75t5"
    , locale: "en-GB"
    , translation: "BUY"
    }
  }
, { translation_key: "dhfgh45tg75t6"
  , locale: "en-US"
  , error: "TRANSLATION_LOCALE_EMPTY"   // Translation string is empty
  , fallback:
    { translation_key: "dhfgh45tg75t6"
    , locale: "en-GB"
    , translation: "Book"
    }
  }
]
```


###Scenario 3 - request body contains translation_key(s) and locales:
e.g. admin goes to modify-translations page

Request body:
```ruby
{ translation_keys:["dhfgh45tg75t3"]
, locales: ["en-US", "en-GB", "fi-FI"]
}
```

Response 200 OK, array of translations in body:
```ruby
[ { translation_key: "dhfgh45tg75t3"
  , locale: "en-US"
  , translation: "Welcome"
  }
, { translation_key: "dhfgh45tg75t3"
  , locale: "en-GB"
  , translation: "Welcome"
  }
, { translation_key: "dhfgh45tg75t3"
  , locale: "fi-FI"
  , error: "TRANSLATION_LOCALE_MISSING" // Translation locale is missing
  , fallback:
    { translation_key: "dhfgh45tg75t3"
    , locale: "en-GB"
    , translation: "Welcome"
    }
  }
]
```



## POST /translations/:community_id/

###Scenario 1 - empty body:

Request no body

Response 400 Bad Request, body:
```ruby
{ error_message: "You must specify an array of locale & translation pairs in your request. e.g. '[{locale: "en-US", translation: "hello"}, {locale: "fi-FI", translation: "Moi"}]'
}
```

###Scenario 2 - request body contains an array of locale & translation pairs:
e.g. admin modifies a static translation

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

Response 201 Created, an array of created translations in body:
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

###Scenario 3 - array of locale & translation pairs with forced translation_key:
e.g. adming creates dynamic translations similar to categories or custom_field_option_titles

Request body:
```ruby
[ { translation_key: "category.1" // explicit translation_key
  , locale: "en-US"
  , translation: "Ceramics"
  }
, { translation_key: "category.1" // explicit translation_key
  , locale: "fi-FI"
  , translation: "Keramiikkaa"
  }
]
```

Response 201 Created, array of created translations in body:
```ruby
[ { translation_key: "category.1"
  , locale: "en-US"
  , translation: "Ceramics"
  }
, { translation_key: "category.1"
  , locale: "fi-FI"
  , translation: "Keramiikka"
  }
]
```

###Scenario 4 - array of locale & translation pairs with forced translation_key:
e.g. adming creates or modifies several static or dynamic translations

Request body:
```ruby
[ { translation_key: "listings.edit.edit_listing"   // translation key exists already
  , locale: "en-US"
  , translation: "Edit product"
  }
, { translation_key: "listings.edit.delete_listing" // translation key does not exists yet
  , locale: "en-US"
  , translation: "Delete product"
  }
]
```

Response 201 Created, array of created and modified translations in body:
```ruby
, { translation_key: "listings.edit.edit_listing"
  , locale: "en-US"
  , translation: "Edit product"
  }
, { translation_key: "listings.edit.delete_listing"
  , locale: "en-US"
  , translation: "Delete product"
  }
]
```


## PUT /translations/:community_id/

we might not need this if POST with scenario 4 is in use.

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
