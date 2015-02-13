module PaypalService::API

  class Process

    ProcessTokenStore = PaypalService::Store::ProcessToken


    # The API implementation
    #

    ## GET /process/:process_token
    def get_status(process_token)
      proc_token = ProcessTokenStore.get_by_process_token(process_token)

      if (proc_token.nil?)
        Result::Error.new("Unknown process token: #{process_token}")
      else
        Result::Success.new(DataTypes.create_process_status({
          process_token: proc_token[:process_token],
          completed: proc_token[:op_completed],
          result: proc_token[:op_output]}))
      end
    end

  end
end
