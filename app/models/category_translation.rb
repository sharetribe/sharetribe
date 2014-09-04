# == Schema Information
#
# Table name: category_translations
#
#  id          :integer          not null, primary key
#  category_id :integer
#  locale      :string(255)
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :string(255)
#
# Indexes
#
#  category_id_with_locale                     (category_id,locale)
#  index_category_translations_on_category_id  (category_id)
#

class CategoryTranslation < ActiveRecord::Base

  attr_accessible :name, :locale, :description, :category_id

  belongs_to :category, touch: true

  validates_presence_of :locale
end
