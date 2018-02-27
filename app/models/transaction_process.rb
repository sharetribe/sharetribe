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
# Indexes
#
#  index_transaction_process_on_community_id  (community_id)
#

class TransactionProcess < ApplicationRecord
  belongs_to :community

  validates :community_id, presence: true
  validates :author_is_seller, inclusion: [true, false]
  validates :process, inclusion: [:none, :preauthorize, :postpay]

  def process
    read_attribute(:process).to_sym
  end
end
