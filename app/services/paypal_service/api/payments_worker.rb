module PaypalService::API::PaymentsWorker

  ProcessTokenStore = PaypalService::Store::ProcessToken


  module_function

  def enqueue_op(community_id:, transaction_id:, op_name:, op_input:)
    proc_token = ProcessTokenStore.create_or_get(
        community_id: community_id,
        transaction_id: transaction_id,
        op_name: op_name,
        op_input: op_input)

    schedule_job(proc_token)
    proc_token
  end


  # Privates

  def schedule_job(proc_token)
    Delayed::Job.enqueue(
      PaypalService::Jobs::ProcessPaymentCommand.new(proc_token[:process_token]))
  end

end
