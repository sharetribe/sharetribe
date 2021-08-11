# == Schema Information
#
# Table name: listing_images
#
#  id                       :integer          not null, primary key
#  listing_id               :integer
#  created_at               :datetime
#  updated_at               :datetime
#  image_file_name          :string(255)
#  image_content_type       :string(255)
#  image_file_size          :integer
#  image_updated_at         :datetime
#  image_processing         :boolean
#  image_downloaded         :boolean          default(FALSE)
#  error                    :string(255)
#  width                    :integer
#  height                   :integer
#  author_id                :string(255)
#  position                 :integer          default(0)
#  email_image_file_name    :string(255)
#  email_image_content_type :string(255)
#  email_image_file_size    :integer
#  email_image_updated_at   :datetime
#  email_hash               :string(255)
#
# Indexes
#
#  index_listing_images_on_listing_id  (listing_id)
#
class ListingImageSerializer < ActiveModel::Serializer
   attributes :id, :listing_id, :created_at, :updated_at, :image_file_name, :image_content_type, :image_file_size, :image_updated_at, :image_processing, :image_downloaded, :error, :width, :height, :author_id, :position, :email_image_file_name, :email_image_content_type, :email_image_file_size, :email_image_updated_at, :email_hash

end