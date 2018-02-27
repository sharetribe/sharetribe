module TransactionService::API
  class Process

    def get(community_id:, process_id: nil)
      if process_id.nil?
        Result::Success.new(TransactionProcess.where(community_id: community_id).to_a)
      else
        process = TransactionProcess.where(community_id: community_id, id: process_id).first
        if process
          Result::Success.new(process)
        else
          Result::Error.new("Cannot find transaction process for community_id: #{community_id} and process_id: #{process_id}")
        end
      end
    end

    def create(community_id:, process:, author_is_seller:)
      process = TransactionProcess.create(community_id: community_id, process: process, author_is_seller: author_is_seller)
      if process
        Result::Success.new(process)
      else
        Result::Error.new("Failed to create new transaction process.")
      end
    end
  end
end
