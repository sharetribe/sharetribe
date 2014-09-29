# == Schema Information
#
# Table name: payments
#
#  id                       :integer          not null, primary key
#  payer_id                 :string(255)
#  recipient_id             :string(255)
#  organization_id          :string(255)
#  transaction_id           :integer
#  status                   :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  community_id             :integer
#  payment_gateway_id       :integer
#  sum_cents                :integer
#  currency                 :string(255)
#  type                     :string(255)      default("CheckoutPayment")
#  braintree_transaction_id :string(255)
#
# Indexes
#
#  index_payments_on_conversation_id  (transaction_id)
#  index_payments_on_payer_id         (payer_id)
#

class CheckoutPayment < Payment

  has_many :rows, :class_name => "PaymentRow", :foreign_key => "payment_id"

  def initialize_rows(community)
    if community.vat
      self.rows = [PaymentRow.new, PaymentRow.new, PaymentRow.new]
    else
      self.rows = [PaymentRow.new]
    end
  end

  def sum_exists?
    !rows.empty?
  end

  def summary_string
    rows.collect(&:title).join(", ")
  end

  # Total payment that will be charged from the payer's account
  def total_sum
    rows.collect(&:sum_with_vat).sum
  end

  # Build default payment sum by listing
  # Note: Consider removing this :(
  def default_sum(listing, vat=0)
    rows.build(title: listing.title, currency: listing.currency, sum: listing.price, vat: vat)
  end
end
