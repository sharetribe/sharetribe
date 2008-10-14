require 'test_helper'

class TransactionsControllerTest < ActionController::TestCase
  
  def setup
    @test_person1, @session1 = get_test_person_and_session("kassi_testperson1")
    @test_person2, @session2 = get_test_person_and_session("kassi_testperson2")
    
    # @valid_transaction = transactions(:valid_transaction)
    # @valid_transaction.sender_id = @test_person1
    # @valid_transaction.receiver_id = @test_person2
  end
  
  def teardown
    @session1.destroy
    @session2.destroy
  end
  

  def test_create_valid_transactions
    post(:create, {:transaction => {:sender_id => @test_person1.id,
                 :receiver_id => @test_person2.id,
                 :amount => 3}})
                 
    assert_response :success  
  end
  
  def test_try_to_create_too_big_transaction
    person1_coin_amount_before = @test_person1.coin_amount
    person2_coin_amount_before = @test_person2.coin_amount
    
    post(:create, {:transaction => {:sender_id => @test_person1.id,
                 :receiver_id => @test_person2.id,
                 :amount => 11}})
    
    assert_template 'new'
    assert_equal(@test_person1.coin_amount, person1_coin_amount_before)
    assert_equal(@test_person2.coin_amount, person2_coin_amount_before)
  end
  
end
