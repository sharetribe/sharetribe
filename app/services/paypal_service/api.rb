module PaypalService
  class Api
    def payments
      PaypalService::API::Payments.new
    end
  end
end
