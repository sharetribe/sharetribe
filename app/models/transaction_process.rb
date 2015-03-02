# == Schema Information
#
# Table name: transaction_processes
#
#  id               :integer          not null, primary key
#  listing_shape_id :integer          not null
#  process          :string(255)
#  author_is_seller :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_transaction_processes_on_listing_shape_id  (listing_shape_id)
#

class TransactionProcess < ActiveRecord::Base
  attr_accessible :process

  belongs_to :listing_shape

  has_many :translations, :class_name => "TransactionProcessTranslation", :dependent => :destroy

  def display_name(locale)
    TranslationCache.new(self, :translations).translate(locale, :name)
  end

end
