module TransactionService::Worker

  ProcessTokenStore = TransactionService::Store::ProcessToken

  JOB_PRIORITY = 0 # Use high priority, user is waiting

  module_function

  def enqueue_preauthorize_op(community_id:, transaction_id:, op_name:, op_input:)
    proc_token = ProcessTokenStore.create(
        community_id: community_id,
        transaction_id: transaction_id,
        op_name: op_name,
        op_input: op_input)

    if proc_token
      schedule_preauthorize_job(proc_token)
      proc_token
    else
      ProcessTokenStore.get_by_transaction(
        community_id: community_id,
        transaction_id: transaction_id,
        op_name: op_name)
    end
  end


  # Privates

  def schedule_preauthorize_job(proc_token)
    Delayed::Job.enqueue(
      TransactionService::Jobs::ProcessPreauthorizeCommand.new(proc_token[:process_token].to_s),
      priority: JOB_PRIORITY)
  end
end
