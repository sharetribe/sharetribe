
module ListingShapeHelper

  module_function

  # deprecated
  #
  # This method is deprecated, but it's still in use in Atom API
  def transaction_type_to_direction(transaction_type)
    transaction_types_to_direction_map(transaction_type.community)[transaction_type.id]
  end

  # deprecated
  #
  # This method is deprecated, but it's still in use in Atom API
  def transaction_types_to_direction_map(community)
    process_res = TransactionService::API::Api.processes.get(
      community_id: community.id,
    )

    direction_tuples = community.transaction_types.map { |tt|
      direction = process_res
                  .maybe
                  .map { |processes| processes.find { |p| p[:id] == tt.transaction_process_id } }
                  .map { |process| process[:author_is_seller] ? "offer" : "request" }
                  .or_else(nil)
                  .tap { |process|
        raise ArgumentError.new("Can not find transaction process for community #{community.id}, transaction type #{tt.id}") if process.nil?
      }

      [tt.id, direction]
    }

    direction_tuples.to_h
  end
end
