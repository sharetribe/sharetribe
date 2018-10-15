# == Schema Information
#
# Table name: community_social_logos
#
#  id                 :integer          not null, primary key
#  community_id       :integer
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  image_processing   :boolean
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_community_social_logos_on_community_id  (community_id)
#

require 'rails_helper'

RSpec.describe Community::SocialLogo, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
