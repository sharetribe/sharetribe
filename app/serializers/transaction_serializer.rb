# == Schema Information
#
# Table name: transactions
#
#  id                                :integer          not null, primary key
#  starter_id                        :string(255)      not null
#  starter_uuid                      :binary(16)       not null
#  listing_id                        :integer          not null
#  listing_uuid                      :binary(16)       not null
#  conversation_id                   :integer
#  automatic_confirmation_after_days :integer          not null
#  community_id                      :integer          not null
#  community_uuid                    :binary(16)       not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  starter_skipped_feedback          :boolean          default(FALSE)
#  author_skipped_feedback           :boolean          default(FALSE)
#  last_transition_at                :datetime
#  current_state                     :string(255)
#  commission_from_seller            :integer
#  minimum_commission_cents          :integer          default(0)
#  minimum_commission_currency       :string(255)
#  payment_gateway                   :string(255)      default("none"), not null
#  listing_quantity                  :integer          default(1)
#  listing_author_id                 :string(255)      not null
#  listing_author_uuid               :binary(16)       not null
#  listing_title                     :string(255)
#  unit_type                         :string(32)
#  unit_price_cents                  :integer
#  unit_price_currency               :string(8)
#  unit_tr_key                       :string(64)
#  unit_selector_tr_key              :string(64)
#  payment_process                   :string(31)       default("none")
#  delivery_method                   :string(31)       default("none")
#  shipping_price_cents              :integer
#  availability                      :string(32)       default("none")
#  booking_uuid                      :binary(16)
#  deleted                           :boolean          default(FALSE)
#  commission_from_buyer             :integer
#  minimum_buyer_fee_cents           :integer          default(0)
#  minimum_buyer_fee_currency        :string(3)
#
# Indexes
#
#  community_starter_state                             (community_id,starter_id,current_state)
#  index_transactions_on_community_id                  (community_id)
#  index_transactions_on_conversation_id               (conversation_id)
#  index_transactions_on_deleted                       (deleted)
#  index_transactions_on_last_transition_at            (last_transition_at)
#  index_transactions_on_listing_author_id             (listing_author_id)
#  index_transactions_on_listing_id                    (listing_id)
#  index_transactions_on_listing_id_and_current_state  (listing_id,current_state)
#  index_transactions_on_starter_id                    (starter_id)
#  transactions_on_cid_and_deleted                     (community_id,deleted)
#
class TransactionSerializer < ActiveModel::Serializer
   attributes :id, :starter_id, :listing_id, :conversation_id, :automatic_confirmation_after_days, :community_id, :created_at, :updated_at, :starter_skipped_feedback, :author_skipped_feedback, :last_transition_at, :current_state, :commission_from_seller, :minimum_commission_cents, :minimum_commission_currency, :payment_gateway, :listing_quantity, :listing_author_id, :listing_title, :unit_type, :unit_price_cents, :unit_price_currency, :unit_tr_key, :unit_selector_tr_key, :payment_process, :delivery_method, :shipping_price_cents, :availability, :deleted, :commission_from_buyer, :minimum_buyer_fee_cents, :minimum_buyer_fee_currency

   has_many :booking

end