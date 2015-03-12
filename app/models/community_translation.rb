# == Schema Information
#
# Table name: community_translations
#
#  id              :integer          not null, primary key
#  community_id    :integer          not null
#  locale          :string(16)       not null
#  translation_key :string(255)      not null
#  translation     :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  community_translations_key         (community_id,translation_key)
#  community_translations_key_locale  (community_id,translation_key,locale)
#

class CommunityTranslation < ActiveRecord::Base
  validates_presence_of :locale, :translation_key

  attr_accessible(
    :community_id,
    :locale,
    :translation_key,
    :translation
  )


end
