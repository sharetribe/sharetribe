module PaypalService::API::PaymentsWorker

  ProcessTokenStore = PaypalService::Store::ProcessToken


  module_function

  def enqueue_op(community_id:, transaction_id:, op_name:, op_input:)
    proc_token = Maybe(
      ProcessTokenStore.create(
        community_id: community_id,
        transaction_id: transaction_id,
        op_name: op_name,
        op_input: op_input))
      .or_else(ProcessTokenStore.get_by_transaction(
        community_id: community_id,
        transaction_id: transaction_id,
        op_name: op_name))

    schedule_job(proc_token)
    proc_token
  end


  # Privates

  def schedule_job(proc_token)
    Delayed::Job.enqueue(PaypalService::Jobs::ProcessPaymentCommand.new(proc_token[:process_token]))
  end

end
