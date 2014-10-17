# Each transtion transition can contain metadata about the transition.
# This file contains datatypes for each transition metadata.
module TransactionService::DataTypes::TransitionMetadata

  TransitionMetadata= EntityUtils.define_builder(
    [:paypal_pending_reason, :string]
    )

  module_function

  def create_metadata(state, data = nil)
    if data
      TransitionMetadata.call(data)
    else
      nil
    end
  end
end
