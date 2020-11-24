module TransactionService::Gateway

  # This is an interface for gateway adapters to provide transaction
  # process settings and validate gateway configurations. In a better
  # world we wouldn't need tx_process_settings method because this is
  # per transaction process configuration, not gateway level
  # stuff. But currently BT settings have not been migrated away from
  # old locations making settings handling gateway specific.
  class SettingsAdapter

    # Return true / false to indicate if the payment gateway is fully
    # configured to handle transactions for the given community and
    # author (listing author / receiver).
    def configured?(community_id:, author_id:)
      raise InterfaceMethodNotImplementedError.new
    end

    def tx_process_settings(tx)
      raise InterfaceMethodNotImplementedError.new
    end
  end
end
