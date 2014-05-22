class MenuLinkTranslation < ActiveRecord::Base
  attr_accessible :locale, :url, :title, :menu_link

  belongs_to :menu_link, touch: true

  validates_presence_of :url
  validates_presence_of :title
  validates_presence_of :locale
end