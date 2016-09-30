# rubocop:disable ConstantName

module PaypalService::API
  Api =
    if Rails.env.test?
      FakeApiImplementation.new(FakePalPStore.new("tmp/test_fakepal.store"))
    else
      ApiImplementation
    end
end
