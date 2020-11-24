module PaypalService::Jobs
  class ProcessPaymentsCommand < Struct.new(:process_token)

    include SessionContextSerializer
    include DelayedAirbrakeNotification

    def perform
      ProcessCommand.run(
        process_token: process_token,
        resolve_cmd: (method :resolve_payment_cmd))
    end


    private

    def resolve_payment_cmd(op_name)
      payments_api.method(op_name)
    end

    def payments_api
      PaypalService::API::Api.payments
    end

  end
end
