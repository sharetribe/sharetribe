module PaypalService
  module API
    API =
      if APP_CONFIG.paypal_implementation&.to_s == "fake"
        store = APP_CONFIG.fakepal_store || "tmp/fakepal.store"

        FakeAPIImplementation.new(FakePalPstore.new(store))
      else
        APIImplementation
      end
  end
end
