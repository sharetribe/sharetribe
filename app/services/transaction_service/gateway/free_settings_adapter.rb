module TransactionService::Gateway
  class FreeSettingsAdapter < SettingsAdapter

    def configured?(community_id:, author_id:)
      true
    end
  end
end
