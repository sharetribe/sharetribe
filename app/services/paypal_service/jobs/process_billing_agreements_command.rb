module PaypalService::Jobs
  class ProcessBillingAgreementsCommand < Struct.new(:process_token)

    include DelayedAirbrakeNotification

    def perform
      ProcessCommand.run(
        process_token: process_token,
        resolve_cmd: (method :resolve_payment_cmd))
    end


    private

    def resolve_payment_cmd(op_name)
      billing_agreements_api.method(op_name)
    end

    def billing_agreements_api
      PaypalService::API::Api.billing_agreements
    end

  end
end
