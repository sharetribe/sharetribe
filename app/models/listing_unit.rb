# == Schema Information
#
# Table name: listing_units
#
#  id                :integer          not null, primary key
#  unit_type         :string(32)       not null
#  quantity_selector :string(32)       not null
#  kind              :string(32)       not null
#  name_tr_key       :string(64)
#  selector_tr_key   :string(64)
#  listing_shape_id  :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_listing_units_on_listing_shape_id  (listing_shape_id)
#

class ListingUnit < ApplicationRecord
  UNIT_TYPES = [
    UNIT = 'unit'.freeze,
    HOUR = 'hour'.freeze,
    DAY = 'day'.freeze,
    NIGHT = 'night'.freeze,
    WEEK = 'week'.freeze,
    MONTH = 'month'.freeze,
    CUSTOM = 'custom'.freeze
  ].freeze

  belongs_to :listing_shape

  validates :unit_type, inclusion: UNIT_TYPES
  validates :kind, inclusion: ['time', 'quantity']
  validates :name_tr_key, presence: true, if: proc { unit_type == 'custom' }
  validates :selector_tr_key, presence: true, if: proc { unit_type == 'custom' }
  validates :quantity_selector, inclusion: [nil, '', 'none', 'number', 'day', 'night'] # in the future include :hour, :week:,:month

  scope :unit_type_hour, -> { where(unit_type: HOUR) }
  scope :unit_type_day_or_night, -> { where(["unit_type = ? OR unit_type = ?", DAY, NIGHT]) }

  def to_unit_hash
    {
      unit_type: unit_type,
      kind: kind,
      quantity_selector: quantity_selector,
      name_tr_key: name_tr_key,
      selector_tr_key: selector_tr_key
    }
  end

  def self.permitted_attributes(unit)
    HashUtils.compact(unit.slice(:unit_type, :quantity_selector, :kind, :name_tr_key, :selector_tr_key))
  end
end
