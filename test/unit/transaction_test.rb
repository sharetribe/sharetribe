require 'test_helper'

class TransactionTest < ActiveSupport::TestCase

  
  def test_has_required_attributes
    transaction_without_sender = transactions(:valid_transaction)
    transaction_without_sender.sender_id = nil
    assert !transaction_without_sender.valid?

    transaction_without_receiver = transactions(:valid_transaction)
    transaction_without_receiver.receiver_id = nil
    assert !transaction_without_receiver.valid?
    
    transaction_without_amount = transactions(:valid_transaction)
    transaction_without_amount.amount = nil
    assert !transaction_without_amount.valid?
  end
  
  def test_amount_valid
    transaction_amount_zero = transactions(:valid_transaction)
    transaction_amount_zero.amount = 0
    assert !transaction_amount_zero.valid?
    
    transaction_amount_less_than_zero = transactions(:valid_transaction)
    transaction_amount_less_than_zero.amount = -3
    assert !transaction_amount_less_than_zero.valid?
  end
  
  
end
