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
