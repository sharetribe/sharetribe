class TransactionProcess < ActiveRecord::Base
  attr_accessible :process
  has_one :transaction_type
end
