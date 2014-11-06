module PaypalService::API::Worker

  ProcessTokenStore = PaypalService::Store::ProcessToken

  module_function

  def enqueue_payments_op(community_id:, transaction_id:, op_name:, op_input:)
    proc_token = ProcessTokenStore.create_or_get(
        community_id: community_id,
        transaction_id: transaction_id,
        op_name: op_name,
        op_input: op_input)

    schedule_payments_job(proc_token)
    proc_token
  end

  def enqueue_billing_agreements_op(community_id:, transaction_id:, op_name:, op_input:)
    proc_token = ProcessTokenStore.create_or_get(
        community_id: community_id,
        transaction_id: transaction_id,
        op_name: op_name,
        op_input: op_input)

    schedule_billing_agreements_job(proc_token)
    proc_token
  end


  # Privates

  def schedule_payments_job(proc_token)
    Delayed::Job.enqueue(
      PaypalService::Jobs::ProcessPaymentsCommand.new(proc_token[:process_token]))
  end

  def schedule_billing_agreements_job(proc_token)
    Delayed::Job.enqueue(
      PaypalService::Jobs::ProcessBillingAgreementsCommand.new(proc_token[:process_token]))
  end

end
