module TransactionService::API
  class Api

    class << self; attr_accessor :settings_api, :transactions_api; end

    def self.transactions
      # TODO Move to TransactionService::API::Transactions
      self.transactions_api ||= TransactionService::Transaction
    end

    def self.settings
      self.settings_api ||= TransactionService::API::Settings.new
    end
  end
end
