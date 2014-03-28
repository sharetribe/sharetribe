class CategoryTransactionType < ActiveRecord::Base
  belongs_to :category
  belongs_to :transaction_type
end
