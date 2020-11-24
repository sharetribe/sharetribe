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
  PROCESSES = [
    PROCESS_NONE = :none,
    PROCESS_PREAUTHORIZE = :preauthorize,
    PROCESS_POSTPAY = :postpay
  ].freeze

  belongs_to :community

  validates :community_id, presence: true
  validates :author_is_seller, inclusion: [true, false]
  validates :process, inclusion: PROCESSES

  scope :process_none, -> { where(process: PROCESS_NONE) }

  def process
    read_attribute(:process).to_sym
  end
end
