# == Schema Information
#
# Table name: listing_shapes
#
#  id                     :integer          not null, primary key
#  community_id           :integer          not null
#  transaction_process_id :integer          not null
#  price_enabled          :boolean          not null
#  shipping_enabled       :boolean          not null
#  name                   :string(255)      not null
#  name_tr_key            :string(255)      not null
#  action_button_tr_key   :string(255)      not null
#  sort_priority          :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted                :boolean          default(FALSE)
#  availability           :string(32)       default("none")
#
# Indexes
#
#  index_listing_shapes_on_community_id  (community_id)
#  index_listing_shapes_on_name          (name)
#  multicol_index                        (community_id,deleted,sort_priority)
#

class ListingShape < ApplicationRecord

  belongs_to :community
  belongs_to :transaction_process
  has_and_belongs_to_many :categories, -> { order("sort_priority") }, join_table: "category_listing_shapes"
  has_many :listing_units

  scope :not_deleted, -> { where(deleted: false).order('sort_priority') }
  scope :by_name, ->(name){ where(name: name) }

  validates :name_tr_key, :action_button_tr_key, :transaction_process_id, presence: true
  validates :price_enabled, :shipping_enabled, inclusion: [true, false]
  validates :availability, inclusion: ['none', 'booking'] # Possibly :stock in the future

  def units
    @_hash_units ||= listing_units.map(&:to_unit_hash)
  end

  DEFAULT_BASENAME = 'order_type'

  def self.create_with_opts(community:, opts:)
    shape = ListingShape.new(ListingShape.permitted_attributes(opts))
    shape.community = community
    shape.name = ListingShape.uniq_name(community.shapes, opts[:basename])
    shape.sort_priority ||= ListingShape.next_sort_priority(community.shapes)

    ListingShape.transaction do
      units = opts.delete(:units)
      if units.present?
        units.each{|unit| shape.listing_units.build(ListingUnit.permitted_attributes(unit)) }
      end
      shape.save!
      shape.assign_to_categories!
    end
    shape
  end

  def update_with_opts(opts)
    ListingShape.transaction do
      new_units = opts.delete(:units)
      if new_units.present?
        self.listing_units.destroy_all
        new_units.each{ |unit| self.listing_units.build(ListingUnit.permitted_attributes(unit)) }
      end
      self.update_attributes!(ListingShape.permitted_attributes(opts))
    end
    self
  end

  def self.permitted_attributes(opts)
    HashUtils.compact(opts.slice(:transaction_process_id, :price_enabled, :shipping_enabled, :name_tr_key, :action_button_tr_key, :sort_priority, :deleted, :availability))
  end

  def self.next_sort_priority(shapes)
    max = shapes.map { |s| s.sort_priority }.max
    max ? max + 1 : 0
  end

  def self.uniq_name(shapes, name_source)
    blacklist = ['new', 'all']
    source = name_source.to_url
    base_name = source.present? ? source : DEFAULT_BASENAME
    current_name = base_name

    i = 1
    while blacklist.include?(current_name) || shapes.detect{ |s| s.name == current_name }.present?
      current_name = "#{base_name}#{i}"
      i += 1
    end
    current_name
  end

  def assign_to_categories!
    community.category_ids.each do |category_id|
      CategoryListingShape.create!(category_id: category_id, listing_shape_id: self.id)
    end
  end
end
