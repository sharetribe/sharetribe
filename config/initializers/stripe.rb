unless defined? STRIPE_JS_HOST
  STRIPE_JS_HOST = 'https://js.stripe.com'
end
STRIPE_COUNTRY_SPECS = JSON.parse(IO.read(Rails.root.join("config/stripe_country_specs_cache.json")))

