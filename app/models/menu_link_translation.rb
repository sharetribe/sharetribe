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
# Indexes
#
#  index_menu_link_translations_on_menu_link_id  (menu_link_id)
#

class MenuLinkTranslation < ApplicationRecord
  belongs_to :menu_link, touch: true

  validates_presence_of :url
  validates_presence_of :title
  validates_presence_of :locale
  validates_length_of :url, maximum: 255
  validates_length_of :title, maximum: 255
end
