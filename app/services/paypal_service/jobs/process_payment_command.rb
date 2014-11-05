module PaypalService::Jobs
  class ProcessPaymentCommand < Struct.new(:process_token)

    ProcessTokenStore = PaypalService::Store::ProcessToken

    def perform
      proc_token = ProcessTokenStore.get_by_process_token(self.process_token)

      payment_cmd = payments_api.method(proc_token[:op_name])
      op_output = payment_cmd.call(*proc_token[:op_input])

      ProcessTokenStore.update_to_completed(
        process_token: proc_token[:process_token],
        op_output: op_output)
    end

    def payments_api
      PaypalService::API::Api.payments
    end

  end
end
