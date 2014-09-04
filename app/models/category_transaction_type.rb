# == Schema Information
#
# Table name: category_transaction_types
#
#  id                  :integer          not null, primary key
#  category_id         :integer
#  transaction_type_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_category_transaction_types_on_category_id          (category_id)
#  index_category_transaction_types_on_transaction_type_id  (transaction_type_id)
#

class CategoryTransactionType < ActiveRecord::Base
  belongs_to :category
  belongs_to :transaction_type
end
