module TransactionService::API
  class Process

    TxProcessStore = TransactionService::Store::TransactionProcess

    def get(community_id:, process_id: nil)
      if process_id.nil?
        Result::Success.new(TxProcessStore.get_all(community_id: community_id))
      else
        Maybe(TxProcessStore.get(community_id: community_id, process_id: process_id))
          .map { |res| Result::Success.new(res) }
          .or_else(Result::Error.new("Cannot find transaction process for community_id: #{community_id} and process_id: #{process_id}"))
      end
    end

    def create(community_id:, process:, author_is_seller:)
      Maybe(TxProcessStore.create(
             community_id: community_id,
             opts: {process: process, author_is_seller: author_is_seller}))
        .map { |m| Result::Success.new(m) }
        .or_else(Result::Error.new("Failed to create new transaction process."))
    end

  end
end
