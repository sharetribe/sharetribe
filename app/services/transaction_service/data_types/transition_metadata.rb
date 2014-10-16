# Each transtion transition can contain metadata about the transition.
# This file contains datatypes for each transition metadata.
module TransactionService::DataTypes::TransitionMetadata

  PendingExt = EntityUtils.define_builder(
    [:pending_reason, :string]
    )

  DATA_TYPE_MAP = {
    pending_ext: PendingExt
  }

  module_function

  def create_metadata(state, data = nil)
    return nil unless data

    Maybe(DATA_TYPE_MAP[state.to_sym]).map { |datatype|
      datatype.call(data)
    }.or_else(nil)
  end
end
