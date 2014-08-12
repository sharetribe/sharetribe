class TransactionType < ActiveRecord::Base
  attr_accessible :community_id, :price_field, :sort_priority, :type, :price_quantity_placeholder

  belongs_to :community

  has_many :translations, :class_name => "TransactionTypeTranslation", :dependent => :destroy, inverse_of: :transaction_type
  has_many :category_transaction_types, :dependent => :destroy
  has_many :categories, :through => :category_transaction_types
  has_many :listings

  validates_presence_of :community

  acts_as_url :url_source, scope: :community_id, sync_url: true, blacklist: %w{new all}

  def url_source
    translation = default_translation_without_cache

    if translation
      translation.name
    else
      type
    end
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
end
