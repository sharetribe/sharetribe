# == Schema Information
#
# Table name: paypal_process_tokens
#
#  id             :integer          not null, primary key
#  process_token  :string(64)       not null
#  community_id   :integer          not null
#  transaction_id :integer          not null
#  op_completed   :boolean          default(FALSE), not null
#  op_name        :string(64)       not null
#  op_input       :text
#  op_output      :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_paypal_process_tokens_on_process_token  (process_token) UNIQUE
#  index_paypal_process_tokens_on_transaction    (transaction_id,community_id,op_name) UNIQUE
#

class PaypalProcessToken < ActiveRecord::Base
  attr_accessible(
    :process_token,
    :community_id,
    :paypal_token,
    :transaction_id,
    :op_completed,
    :op_name,
    :op_input,
    :op_output)

  validates_presence_of(:process_token, :community_id)

end
