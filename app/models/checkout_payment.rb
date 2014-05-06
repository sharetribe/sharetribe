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

  # Payment excluding VAT and commission
  def sum_without_vat_and_commission
    rows.inject(Money.new(0, rows.first.currency)) { |total, row| total += row.sum }
  end

  # Total payment with VAT but without commission
  def sum_without_commission
    rows.inject(Money.new(0, rows.first.currency)) { |total, row| total += row.sum_with_vat }
  end

  def summary_string
    rows.collect(&:title).join(", ")
  end

  # Total payment that will be charged from the payer's account
  def total_sum
    sum_without_commission
  end

  # Commission excluding VAT
  def commission_without_vat
    throw "Comission percentage has to be set" unless community.commission_from_seller
    sum_without_vat_and_commission * community.commission_from_seller/100
  end

  # Commission including VAT
  def total_commission
    sum_with_percentage(commission_without_vat, APP_CONFIG.service_fee_tax_percentage.to_i)
  end

end
