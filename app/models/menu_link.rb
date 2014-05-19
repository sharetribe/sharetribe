class MenuLink < ActiveRecord::Base
  has_many :translations, :class_name => "MenuLinkTranslation", :dependent => :destroy
  belongs_to :community

  validates_presence_of :community

  def url(locale)
    TranslationCache.new(self, :translations).translate(locale, :url)
  end

  def title(locale)
    TranslationCache.new(self, :translations).translate(locale, :title)
  end
end