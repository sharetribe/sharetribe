class TransactionType < ActiveRecord::Base
  attr_accessible :community_id, :price_field, :sort_priority, :type, :price_quantity_placeholder

  belongs_to :community

  has_many :translations, :class_name => "TransactionTypeTranslation", :dependent => :destroy, inverse_of: :transaction_type
  has_many :category_transaction_types, :dependent => :destroy
  has_many :categories, :through => :category_transaction_types
  has_many :listings

  validates_presence_of :community

  validates :price_per, inclusion: { in: %w(day),
    message: "%{value} is not valid" }

  acts_as_url :url_source, scope: :community_id, sync_url: true, blacklist: %w{new all}

  def to_param
    url
  end

  def url_source
    Maybe(default_translation_without_cache).name.or_else(type)
  end

  def default_translation_without_cache
    (translations.find { |translation| translation.locale == community.default_locale } || translations.first)
  end

  def display_name(locale)
    TranslationCache.new(self, :translations).translate(locale, :name)
  end

  def action_button_label(locale)
    TranslationCache.new(self, :translations).translate(locale, :action_button_label)
  end

  def status_after_reply
    "free"
  end

  def self.find_by_url_or_id(url_or_id)
    self.find_by_url(url_or_id) || self.find_by_id(url_or_id)
  end
end
