class PaymentRow < ActiveRecord::Base

  include MathHelper

  attr_accessible :payment_id, :vat, :sum, :currency, :title

  belongs_to :payment

  monetize :sum_cents

  def sum_with_vat
    sum_with_percentage(sum, vat)
  end

  # The price symbol based on this listing's price or community default, if no price set
  def sum_symbol
    sum ? sum.symbol : MoneyRails.default_currency.symbol
  end

end
