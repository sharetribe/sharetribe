# rubocop:disable ConstantName

module PaypalService::API
  Api =
    if Rails.env.test?
      FakeApiImplementation
    else
      FakeApiImplementation
    end
end
