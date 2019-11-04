# == Schema Information
#
# Table name: aucsions
#
#  id                  :bigint           not null, primary key
#  listing_id          :bigint
#  person_id           :string(255)
#  price_aucsion_cents :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_aucsions_on_listing_id  (listing_id)
#

class Aucsion < ApplicationRecord
  belongs_to :listing

  validate :price_update_listing, on: :update

  monetize :price_aucsion_cents, allow_nil: true, with_model_currency: :currency

  private

  def price_update_listing
    return if price_aucsion_cents_changed? && price_aucsion_cents > price_aucsion_cents_was

    errors[:base] << "You can not reduce the price!"
  end
end
