# Configure Harmony service for availability management

This guide instructs you to configure your marketplace to use [Harmony](https://www.github.com/sharetribe/harmony) service for availability management.

This guide does not instruct how to install and run Harmony. See [README.md](https://github.com/sharetribe/harmony/blob/master/README.md) in Harmony repository for installation instructions.

## Prerequisites

* Sharetribe version 6.2.0 or newer
* Harmony service up and running
* Marketplace configured to use transaction process with PayPal payments.

The availability management is tightly coupled to the transaction process, so PayPal payments need to be enabled to use availability management.

## Getting started

1. Make sure that Harmony is up and running

  Try to open: [http://localhost:8085/apidoc/index.html](http://localhost:8085/apidoc/index.html)

  If everything goes well, you should see the Swagger UI.

  If you are running Harmony service in other location than `http://localhost:8085` (e.g. different port) you need to change the URL. `http://localhost:8085` is the default location.

1. Enable Harmony

  Add the following configuration to your `config.yml` file:

  ```
  # Harmony service API connection
  harmony_api_in_use: true
  ```

1. Restart Rails server

  As always, Rails server needs to be restarted after configurations are changed.

1. Enable availability management for Order types

  Go to Admin > Order Types and edit the order types to enable daily or nightly availability.

1. Done!

  If everything went ok, you should be now able to add listings with availability management enabled!

## Advanced configurations

**Harmony URL**

If you're running Harmony in other location than `http://localhost:8085`, you need to change `harmony_api_url` configuration. Add the following to your `config.yml`:

```
harmony_api_url: <your host url here>
```

**Token secret**

Before going to production, you should change the default API token secret. This key is used to authorize requests in Harmony API. Add the following to your `config.yml`:

```
harmony_api_token_secret: <your long api token secret key here>
```

You need to set the same value to the Harmony API. See Harmony [README.md](https://www.github.com/sharetribe/harmony/blob/master/README.md) for instructions.
