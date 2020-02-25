# == Schema Information
#
# Table name: community_social_logos
#
#  id                 :bigint           not null, primary key
#  community_id       :bigint
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

class Community::SocialLogo < ApplicationRecord
  belongs_to :community

  has_attached_file :image,
                    :styles => {
                      :thumbnail => "200x100#",
                      :original => "1200x600>"
                    },
                    :convert_options => {
                      # iOS makes logo background black if there's an alpha channel
                      # And the options has to be in correct order! First background, then flatten. Otherwise it will
                      # not work.
                      :apple_touch => "-background white -flatten"
                    },
                    :keep_old_files => true

  validates_attachment_content_type :image,
                                    :content_type => IMAGE_CONTENT_TYPE

  attr_reader :destroy_image

  def destroy_image=(value)
    if value == '1'
      image.destroy
    end
  end
end
