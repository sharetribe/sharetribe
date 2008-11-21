require 'test_helper'

class TransactionTest < ActiveSupport::TestCase

  
  # def test_has_required_attributes
  #   transaction_without_sender = transactions(:valid_transaction)
  #   transaction_without_sender.sender_id = nil
  #   assert !transaction_without_sender.valid?
  # 
  #   transaction_without_receiver = transactions(:valid_transaction)
  #   transaction_without_receiver.receiver_id = nil
  #   assert !transaction_without_receiver.valid?
  #   
  #   transaction_without_amount = transactions(:valid_transaction)
  #   transaction_without_amount.amount = nil
  #   assert !transaction_without_amount.valid?
  # end
  # 
  # def test_amount_valid
  #   transaction_amount_zero = transactions(:valid_transaction)
  #   transaction_amount_zero.amount = 0
  #   assert !transaction_amount_zero.valid?
  #   
  #   transaction_amount_less_than_zero = transactions(:valid_transaction)
  #   transaction_amount_less_than_zero.amount = -3
  #   assert !transaction_amount_less_than_zero.valid?
  # end
  
  def setup
    @test_person1, @session1 = get_test_person_and_session("kassi_testperson1")
    @test_person2, @session2 = get_test_person_and_session("kassi_testperson2")
   
    @cookie = @session1.cookie
  end
  
  def teardown
    @session1.destroy
  end
    
  def test_create_transaction
    #create with receiver id only
    t1 = Transaction.create({:receiver_id => @test_person1.id, :amount => 5, :sender_id => @test_person2.id  })
    assert_not_nil(t1)
    assert t1.amount == 5
    
    #create with receiver username only
    t2 = Transaction.create({:receiver_username => "kassi_testperson2", 
                        :amount => 5, 
                        :sender_id => @test_person1.id, 
                        :description => "Kuvaus tapahtumista.", 
                        :listing_id => 168  })
    assert_not_nil(t2)
  end
  
  
end
