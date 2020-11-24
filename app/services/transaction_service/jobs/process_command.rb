module TransactionService::Jobs::ProcessCommand

  ProcessTokenStore = TransactionService::Store::ProcessToken

  module_function

  def run(process_token:, resolve_cmd:)
    proc_token = ProcessTokenStore.get_by_process_token(process_token)

    payment_cmd = resolve_cmd.call(proc_token[:op_name])
    op_output = payment_cmd.call(*proc_token[:op_input])

    ProcessTokenStore.update_to_completed(
      process_token: proc_token[:process_token],
      op_output: op_output)
  end

end
