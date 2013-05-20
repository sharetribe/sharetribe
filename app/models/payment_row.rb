class PaymentRow < ActiveRecord::Base
  
  attr_accessible :payment_id, :vat, :sum, :sum_currency, :title
  
  belongs_to :payment
  
  monetize :sum_cents
  
end
