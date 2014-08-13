# == Schema Information
#
# Table name: menu_link_translations
#
#  id           :integer          not null, primary key
#  menu_link_id :integer
#  locale       :string(255)
#  url          :string(255)
#  title        :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class MenuLinkTranslation < ActiveRecord::Base
  attr_accessible :locale, :url, :title, :menu_link

  belongs_to :menu_link, touch: true

  validates_presence_of :url
  validates_presence_of :title
  validates_presence_of :locale
end
