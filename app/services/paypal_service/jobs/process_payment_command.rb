module PaypalService::Jobs
  class ProcessPaymentCommand < Struct.new(:process_token)

    def perform
      binding.pry
    end
  end
end
