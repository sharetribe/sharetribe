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
  , translation: nil
  , error: "TRANSLATION_KEY_MISSING"    // Translation key is missing.
  }
, { translation_key: "dhfgh45tg75t5"
  , locale: "en-GB"
  , translation: "BUY"
  , warn: "TRANSLATION_LOCALE_MISSING"  // Translation locale is missing, using fallback
  }
, { translation_key: "dhfgh45tg75t6"
  , locale: "en-GB"
  , translation: "Book",
  , warn: "TRANSLATION_LOCALE_MISSING" // Translation string is empty, using fallback
  }
]
```


###Scenario 3 - request body contains translation_key(s) and locales:
e.g. admin goes to modify-translations page

Request body:
```ruby
{ translation_keys:["dhfgh45tg75t3"]
, locales: ["en-US", "en-GB", "fi-FI"]
, use_fallback: false // Defaults to true when not passed explicitly
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
  , translation: nil
  , error: "TRANSLATION_LOCALE_MISSING" // Translation locale is missing
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

###Scenario 2 - request body contains locale & translation pairs in arrays of shared translation keys:
e.g. admin modifies a static translation

Request body:
```ruby
[ { translation_key: nil // optional key - if defined it will override previous translations
  , translations:
    [ { locale: "en-US"
      , translation: "Welcome"
      }
    , { locale: "fi-FI"
      , translation: "Tervetuloa"
      }
    ]
  }
, { translation_key: nil // optional key - if defined it will override previous translations
  , translations:
    [ { locale: "en-US"
      , translation: "Hi"
      }
    , { locale: "fi-FI"
      , translation: "Moi"
      }
    ]
  }
}
]
```

Response 201 Created, an array of created translations (grouped the same way as in request) in body:
```ruby
[ { translation_key: "dfnv7858vfjgk"
  , translations:
      [ { translation_key: "dfnv7858vfjgk"
        , locale: "en-US"
        , translation: "Welcome"
        }
      , { translation_key: "dfnv7858vfjgk"
        , locale: "fi-FI"
        , translation: "Tervetuloa"
        }
      ]
  }
, { translation_key: "tr54rdfgdrted"
  , translations:
      [ { translation_key: "tr54rdfgdrted"
        , locale: "en-US"
        , translation: "Hi"
        }
      , { translation_key: "tr54rdfgdrted"
        , locale: "fi-FI"
        , translation: "Moi"
        }
      ]
  }
]
```

###Scenario 3 - array of locale & translation pairs with forced translation_key:
e.g. adming creates dynamic translations similar to categories or custom_field_option_titles

Request body:
```ruby
[ { translation_key: "category.1" // override translations under key "category.1"
  , translations:
      [ { translation_key: "category.1"
        , locale: "en-US"
        , translation: "Ceramics"
        }
      , { translation_key: "category.1"
        , locale: "fi-FI"
        , translation: "Keramiikkaa"
        }
      ]
  }
]
```

Response 201 Created, array of created translations in body:
```ruby
[ { translation_key: "category.1"
  , translations:
      [ { translation_key: "category.1"
        , locale: "en-US"
        , translation: "Ceramics"
        }
      , { translation_key: "category.1"
        , locale: "fi-FI"
        , translation: "Keramiikka"
        }
      ]
  }
]
```

###Scenario 4 - array of locale & translation pairs with forced translation_key:
e.g. adming creates or modifies several static or dynamic translations

Request body:
```ruby
[ { translation_key: "listings.edit.edit_listing"
  , translations:
      [ { translation_key: "listings.edit.edit_listing"   // translation key exists already e.g. "Edit listing"
        , locale: "en-US"
        , translation: "Edit product"
        }
      ]
  }
]
```

Response 201 Created, array of created and modified translations in body:
```ruby
[ { translation_key: "listings.edit.edit_listing"
  , translations:
      [ { translation_key: "listings.edit.edit_listing"
        , locale: "en-US"
        , translation: "Edit product"
        }
      ]
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
[ { translation_keys: ["dfnv7858vfjgk"]
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
