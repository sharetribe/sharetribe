# == Schema Information
#
# Table name: community_translations
#
#  id              :integer          not null, primary key
#  community_id    :integer          not null
#  locale          :string(16)       not null
#  translation_key :string(255)      not null
#  translation     :text(65535)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_community_translations_on_community_id  (community_id)
#

class CommunityTranslation < ApplicationRecord
  validates_presence_of :locale, :translation_key

end
