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

class CategoryTranslation < ActiveRecord::Base

  attr_accessible :name, :locale, :description, :category_id

  belongs_to :category, touch: true

  validates_presence_of :locale
end
