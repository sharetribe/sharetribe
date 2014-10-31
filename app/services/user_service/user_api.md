
# user/v1/

## GET /int_api/users/email_available

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
