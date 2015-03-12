# == Schema Information
#
# Table name: transaction_types
#
#  id                         :integer          not null, primary key
#  type                       :string(255)
#  community_id               :integer
#  transaction_process_id     :integer
#  sort_priority              :integer
#  price_field                :boolean
#  preauthorize_payment       :boolean          default(FALSE)
#  price_quantity_placeholder :string(255)
#  price_per                  :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  url                        :string(255)
#
# Indexes
#
#  index_transaction_types_on_community_id  (community_id)
#  index_transaction_types_on_url           (url)
#

class Offer < TransactionType

  def direction
    raise "Offer.direction is deprecated"
    "offer"
  end

  def is_offer?
    raise "Offer.is_offer is deprecated"
    true
  end

  def is_request?
    raise "Offer.is_request is deprecated"
    false
  end

  def is_inquiry?
    # We still need this method to define whether to show the contact button or not
    # raise "Offer.is_inquiry is deprecated"
    false
  end

  def status_after_reply
    raise "Offer.status_after_reply is deprecated"
    process_res = TransactionService::API::Api.processes.get(
      community_id: community_id,
      process_id: transaction_process_id
    )

    case process_res.data[:process]
    when :preauthorize
      "preauthorize"
    when :postpay
      "pending"
    when :none
      "free"
    else
      raise ArgumentError.new("Can not find order flow for process #{process}")
    end
  end

end
