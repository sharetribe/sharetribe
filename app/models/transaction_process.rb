# == Schema Information
#
# Table name: transaction_processes
#
#  id               :integer          not null, primary key
#  community_id     :integer
#  process          :string(32)       not null
#  author_is_seller :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class TransactionProcess < ActiveRecord::Base
  attr_accessible(
    :community_id,
    :process
  )
end
