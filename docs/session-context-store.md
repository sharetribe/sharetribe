# SessionContextStore

[SessionContextStore](/app/services/session_context_store.rb) is a global object that holds information about the current session, that is, current community and current user.

## When to use SessionContextStore

When you should use SessionContextStore? The answer is, **almost never**. In the end, the SessionContextStore is a mutable global object. If used in a wrong places, you may end up bypassing all the nice structure we've been building for the app and you'll end up with big bowl of spaghetti.

However, in some **exceptional** cases, it may not be wise to pass user/community information from method to method, but instead bypass those. One of such cases is calls to external APIs. E.g. call to Harmony API requires current user UUID and current marketplace UUID and using SessionContextStore for that makes the code simpler and easier. Other example that comes to mind is logging. It might be useful to include user UUID and marketplace UUID to the log entry, but passing that information from method to method just because of logging might make the code more messy than it should be.

## Basic usage

To fetch the session information, call `SessionContextStore.get`:

```
[1] pry> SessionContextStore.get
{
      :marketplace_id => 1,
    :marketplace_uuid => #<UUID:0x3fda7032b04c UUID:ee5e7532-a190-11e6-9c6a-28cfe91d00c3>,
             :user_id => "6eWcdOBX_d3Vhm22viSRTw",
           :user_uuid => #<UUID:0x3fda70323d9c UUID:eef327ea-a190-11e6-9c6a-28cfe91d00c3>,
           :user_role => :admin
}
```

## Initialization

The SessionContextStore needs to be initialized with the session data. The initialization happens automatically by Rack middleware [SessionContextMiddleware](/lib/rack_middleware/session_context_middleware.rb)

In background jobs, where the middleware is not run, you need to include [SessionContextSerializer](/app/jobs/session_context_serializer.rb) to the job. The serializer will then serialize and deserialize the content of SessionContextStore.

In other context, such as scheduled task, you need to initialize the store manually, by calling `SessionContextStore.set`.
