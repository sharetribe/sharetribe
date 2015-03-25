# == Schema Information
#
# Table name: transaction_types
#
#  id                         :integer          not null, primary key
#  community_id               :integer
#  transaction_process_id     :integer
#  sort_priority              :integer
#  price_field                :boolean
#  price_quantity_placeholder :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  url                        :string(255)
#  shipping_enabled           :boolean          default(FALSE)
#  name_tr_key                :string(255)
#  action_button_tr_key       :string(255)
#
# Indexes
#
#  index_transaction_types_on_community_id  (community_id)
#  index_transaction_types_on_url           (url)
#

class TransactionType < ActiveRecord::Base
  attr_accessible(
    :community_id,
    :price_field,
    :sort_priority,
    :price_quantity_placeholder,
    :transaction_process_id,
    :shipping_enabled,
    :name_tr_key,
    :action_button_tr_key,
    :url
  )

  belongs_to :community

  has_many :translations, :class_name => "TransactionTypeTranslation", :dependent => :destroy, inverse_of: :transaction_type
  has_many :category_transaction_types, :dependent => :destroy
  has_many :categories, :through => :category_transaction_types
  has_many :listing_units

  validates_presence_of :community

  # TODO this can be removed
  def self.columns
    super.reject { |c| c.name == "type" || c.name == "preauthorize_payment" || c.name == "price_per" }
  end

  # TODO this can be removed
  def self.inheritance_column
    :a_non_existing_column_because_we_want_to_disable_inheritance
  end

  def to_param
    url
  end

  def display_name(locale)
    result = TranslationService::API::Api.translations
      .get(community_id, {
        translation_keys: [name_tr_key],
        locales: community.locales
           })
    find_any_translation(result[:data], locale)
  end

  def action_button_label(locale)
    result = TranslationService::API::Api.translations
      .get(community_id, {
        translation_keys: [action_button_tr_key],
        locales: community.locales,
        fallback_locale: community.default_locale
      })
    find_any_translation(result[:data], locale)
  end

  def self.find_by_url_or_id(url_or_id)
    self.find_by_url(url_or_id) || self.find_by_id(url_or_id)
  end

  private

  def find_any_translation(data, preferred_locale)
    tr_hash = data.find {|tr| tr[:locale] == preferred_locale.to_s && tr[:translation].present? }
    tr_hash = data.find {|tr| tr[:locale] == community.default_locale && tr[:translation].present? } if tr_hash.nil?
    tr_hash = data.find {|tr| tr[:translation].present?} if tr_hash.nil?
    raise ArgumentError.new("translations missing for transaction type") if tr_hash.nil?
    tr_hash[:translation]
  end
end
