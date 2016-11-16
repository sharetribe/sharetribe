# rubocop:disable ConstantName

module PaypalService
  module API
    Api =
      if APP_CONFIG.paypal_implementation&.to_s == "fake"
        store = APP_CONFIG.fakepal_store || "tmp/fakepal.store"

        FakeApiImplementation.new(FakePalPstore.new(store))
      else
        ApiImplementation
      end
  end
end
