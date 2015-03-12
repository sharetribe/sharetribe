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

class Request < TransactionType

  DEFAULTS = {
    price_field: 0
  }

  before_validation(:on => :create) do
    self.price_field ||= DEFAULTS[:price_field]
  end

  def direction
    raise "Request.direction is deprecated"
    "request"
  end

  def is_offer?
    raise "Request.is_offer is deprecated"
    false
  end

  def is_request?
    raise "Request.is_request is deprecated"
    true
  end

  def is_inquiry?
    # We still need this method to define whether to show the contact button or not
    # raise "Request.is_inquiry is deprecated"
    false
  end

end
