# Extremely early stage implementation of Transcation Process API

module TransactionService::API

  class Process

    def get(community_id:, process_id: nil)
      # TODO Move this logic to behind Store layer
      result_data =
        if process_id.nil?
          TransactionProcess.where(community_id: community_id).map { |process_model|
            model_to_hash(process_model)
          }
        else
          model_to_hash(TransactionProcess.where(community_id: community_id, id: process_id).first)
        end

      Result::Success.new(result_data)
    end

    def create(community_id:, process:, author_is_seller:)
      # TODO Move this logic to behind Store layer
      Result::Success.new(
        model_to_hash(
          TransactionProcess.create!(
          {
            community_id: community_id,
            process: process,
            author_is_seller: author_is_seller
          })))
    end

    # private

    def model_to_hash(m)
      return nil if m.nil?

      {
        id: m.id,
        community_id: m.community_id,
        author_is_seller: m.author_is_seller,
        process: m.process.to_s # convert to string, because we can not transfer symbols with JSON
      }
    end

  end

end
