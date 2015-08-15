# process/v1/

## GET /:community_id/:process_id

Request: Empty

Response:

```json
{
  id: 123,
  process: "preauthorize" # or "none" or "postpay"
}
```

## GET /:community_id/

Request: Empty

Response:


```json
{
  id: 123,
  process: "preauthorize" # or "none" or "postpay"
}
```

## POST /:community_id

Request:


```json
{
  id: 123,
  process: "preauthorize" # or "none" or "postpay"
}
```
