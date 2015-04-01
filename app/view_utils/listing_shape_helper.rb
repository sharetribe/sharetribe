
module ListingShapeHelper

  module_function

  # deprecated
  #
  # This method is deprecated, but it's still in use in Atom API
  def transaction_type_to_direction(transaction_type)
    transaction_types_to_direction_map(transaction_type.community)[transaction_type.id]
  end

  def transaction_type_id_to_direction(transaction_type_id, community)
    transaction_types_to_direction_map(community)[transaction_type_id]
  end

  # deprecated
  #
  # This method is deprecated, but it's still in use in Atom API
  def transaction_types_to_direction_map(community)
    process_res = TransactionService::API::Api.processes.get(
      community_id: community.id
    )

    shapes = ListingService::API::Api.shapes.get(community_id: community.id).maybe.or_else([])

    direction_tuples = shapes.map { |shape|
        direction = process_res
          .maybe
          .map { |processes| processes.find { |p| p[:id] == shape[:transaction_process_id] } }
          .map { |process| process[:author_is_seller] ? "offer" : "request" }
          .or_else(nil)
          .tap { |process|
            raise ArgumentError.new("Can not find transaction process for community #{community.id}, transaction type #{s[:transaction_type_id]}") if process.nil?
        }

      [shape[:transaction_type_id], direction]
    }

    direction_tuples.to_h
  end
end
