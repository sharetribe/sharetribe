
# marketplace/v1/

## POST /int_api/create_trial_marketplace

Request body:

```ruby
{ admin_email: "eddie.admin@example.com"
, admin_first_name: "Eddie"
, admin_last_name: "Admin"
, admin_password: "secret_word"
, marketplace_country: "FI"
, marketplace_language: "fi"
, marketplace_name: "ImaginationTraders"
, marketplace_type: "product"    # or "rental" or "service"
}
```

Response 201 Created, body:

```ruby
{ marketplace_url: "https://imaginationtraders.sharetribe.com"
}
```



## GET /int_api/check_email_availability

Temporary side effect is that the asked email is

Request body:

```ruby
{ email: "eddie.ejemplo@example.com"
}
```

Response 200 Ok, body:

```ruby
{ email: "eddie.ejemplo@example.com",
  available: false
}
```

