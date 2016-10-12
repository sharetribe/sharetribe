# Using Fakepal

Fakepal is a fake PayPal implementation that can be used for development purposes. It's also used by the unit and feature tests.

## Turn on Fakepal

To use Fakepal, change the value of `paypal_implementation` environment variable from `real` to `fake`. You can either edit the `config.yml` file or pass the environment variable while starting the Rails server:

```
> paypal_implementation=fake rails s
```

## File storage

Fakepal uses file based storage to store account information. Change the value of `fakepal_store` environment variable to control the file location.
