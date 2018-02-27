module TransactionService::API
  class Api

    class << self
      attr_accessor(
        :settings_api,
        :processes_api,
        :process_tokens_api
      )
    end

    def self.settings
      self.settings_api ||= TransactionService::API::Settings.new
    end

    def self.processes
      self.processes_api ||= TransactionService::API::Process.new
    end

    def self.process_tokens
      self.process_tokens_api ||= TransactionService::API::ProcessTokens.new
    end
  end
end
