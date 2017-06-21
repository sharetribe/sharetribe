# == Schema Information
#
# Table name: transaction_process_tokens
#
#  id             :integer          not null, primary key
#  process_token  :binary(16)
#  community_id   :integer          not null
#  transaction_id :integer          not null
#  op_completed   :boolean          default(FALSE), not null
#  op_name        :string(64)       not null
#  op_input       :text(65535)
#  op_output      :text(65535)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_paypal_process_tokens_on_transaction         (transaction_id,community_id,op_name) UNIQUE
#  index_transaction_process_tokens_on_process_token  (process_token) UNIQUE
#

class TransactionProcessToken < ApplicationRecord
end
