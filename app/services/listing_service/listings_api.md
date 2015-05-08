
# listings/v1/

## GET /:community_id

**This endpoint is not implemented yet**

Request params:

* q: "Search string"
* category: "tools"
* open: true/false

etc...

Response:

```ruby
[ { id: 123,
  , title: "Power drill"
  , ...
  }
, { id: 234,
  , title: "Saw"
  , ...
  }
]
```

## GET /:community_id/count

Request params:

Same as above

* q: "Search string"
* category: "category_name"
* open: true/false

etc...

Response:

```ruby
123
```

## PUT /:community_id/

Request params:

* listing\_shape\_id: 123

Request body:

```ruby
{
  open: boolean
}
```
