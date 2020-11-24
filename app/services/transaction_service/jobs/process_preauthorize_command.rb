module TransactionService::Jobs
  class ProcessPreauthorizeCommand < Struct.new(:process_token)

    include SessionContextSerializer
    include DelayedAirbrakeNotification

    def perform
      ProcessCommand.run(
        process_token: UUIDTools::UUID.parse(process_token),
        resolve_cmd: (method :resolve_preauthorize_cmd))
    end


    private

    def resolve_preauthorize_cmd(op_name)
      preauthorize_process.method(op_name)
    end

    def preauthorize_process
      @preauth_process ||= TransactionService::Process::Preauthorize.new
    end

  end
end
