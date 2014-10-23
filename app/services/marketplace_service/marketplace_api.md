
# marketplace/v1/

## POST /marketplaces

Request body:

```ruby
{ admin_email: "eddie.admin@example.com"
, admin_first_name: "Eddie"
, admin_last_name: "Admin"
, admin_password: "secret_word"
, marketplace_country: "Finland"
, marketplace_language: "fi"
, marketplace_name: "ImaginationTraders"
, marketplace_type: :product    # or :rental or :service
}
```

Response 201 Created, body:

```ruby
{ marketplace_url: "https://imaginationtraders.sharetribe.com"
}
```
