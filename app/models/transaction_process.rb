# == Schema Information
#
# Table name: transaction_processes
#
#  id         :integer          not null, primary key
#  process    :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TransactionProcess < ActiveRecord::Base
  attr_accessible :process
  has_one :transaction_type
end
