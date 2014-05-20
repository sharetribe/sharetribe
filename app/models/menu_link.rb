class MenuLink < ActiveRecord::Base
  has_many :translations, :class_name => "MenuLinkTranslation", :dependent => :destroy
  belongs_to :community

  validates_presence_of :community

  def translation_attributes=(attributes)
    attributes.each do |locale, value|
      if translation = translations.find_by_locale(locale)
        translation.update_attributes(value)
      else
        translation = translations.build(value.merge(locale: locale))
      end
    end
  end

  def url(locale)
    TranslationCache.new(self, :translations).translate(locale, :url)
  end

  def title(locale)
    TranslationCache.new(self, :translations).translate(locale, :title)
  end
end