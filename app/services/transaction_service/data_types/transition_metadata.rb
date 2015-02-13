# Each transtion transition can contain metadata about the transition.
# This file contains datatypes for each transition metadata.
module TransactionService::DataTypes::TransitionMetadata

  TransitionMetadata= EntityUtils.define_builder(
    [:paypal_pending_reason, :symbol],
    [:paypal_payment_status, :symbol]
  )

  module_function

  def create_metadata(data); TransitionMetadata.call(data) end

end
