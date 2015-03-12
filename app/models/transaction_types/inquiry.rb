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

class Inquiry < TransactionType

  DEFAULTS = {}

  def direction
    raise "Inquiry.direction is deprecated"
    "inquiry"
  end

  def is_offer?
    raise "Inquiry.is_offer is deprecated"
    false
  end

  def is_request?
    raise "Inquiry.is_request is deprecated"
    false
  end

  def is_inquiry?
    # We still need this method to define whether to show the contact button or not
    # raise "Inquiry.is_inquiry is deprecated"
    true
  end

end
