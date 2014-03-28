module BraintreePaymentsHelper
  def pad(n)
    n < 10 ? '0' + n.to_s : n
  end

  def credit_card_expiration_month_options
    (1..12).map { |m| [pad(m), m] }
  end

  def credit_card_expiration_year_options
    years = 20
    start_year = Date.today.year
    end_year = start_year + 20

    (start_year..end_year).map { |m| [m, m] }
  end
end
