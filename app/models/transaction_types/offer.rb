# == Schema Information
#
# Table name: transaction_types
#
#  id                         :integer          not null, primary key
#  type                       :string(255)
#  community_id               :integer
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
    "offer"
  end

  def is_offer?
    true
  end

  def is_request?
    false
  end

  def is_inquiry?
    false
  end

  def status_after_reply
    if price_field? && community.payments_in_use?
      if preauthorize_payment?
        "preauthorize"
      else
        "pending"
      end
    else
      "free"
    end
  end

end
