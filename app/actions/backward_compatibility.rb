# All methods is tnis module are DEPRECATED!
#
# Do not use them to build anything new.
#
# The functions in this module support backward compatibility with parts
# of the application that we can not just change, e.g. API
#
module BackwardCompatibility

  module_function

  def transaction_type_to_direction(transaction_type)
    transaction_types_to_direction_map(transaction_type.community)[transaction_type.id]
  end

  def transaction_types_to_direction_map(community)
    process_res = TransactionService::API::Api.processes.get(
      community_id: community.id,
    )

    community.transaction_types.inject({}) { |direction_map, tt|
      direction_map.tap { |m|
        process = process_res.data.find { |p| p[:id] == tt.transaction_process_id }

        direction = process[:author_is_seller] ? "offer" : "request"
        m[tt.id] = direction
      }
    }
  end
end
