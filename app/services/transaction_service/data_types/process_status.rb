module TransactionService::DataTypes::ProcessStatus

  ProcessStatus = EntityUtils.define_builder(
    [:process_token, :mandatory, :uuid],
    [:completed, :mandatory, :to_bool],
    [:result])

  module_function

  def create_process_status(opts)
    ProcessStatus.call(opts)
  end

end
