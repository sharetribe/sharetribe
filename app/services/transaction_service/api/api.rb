module TransactionService::API
  class Api

    class << self
      attr_accessor(
        :settings_api,
        :transactions_api,
        :processes_api
      )
    end

    def self.transactions
      # TODO Move to TransactionService::API::Transactions
      self.transactions_api ||= TransactionService::Transaction
    end

    def self.settings
      self.settings_api ||= TransactionService::API::Settings.new
    end

    def self.processes
      self.processes_api ||= TransactionService::API::Process.new
    end
  end
end
