# == Schema Information
#
# Table name: people
#
#  id                                 :string(22)       not null, primary key
#  uuid                               :binary(16)       not null
#  community_id                       :integer          not null
#  created_at                         :datetime
#  updated_at                         :datetime
#  is_admin                           :integer          default(0)
#  locale                             :string(255)      default("fi")
#  preferences                        :text(65535)
#  active_days_count                  :integer          default(0)
#  last_page_load_date                :datetime
#  test_group_number                  :integer          default(1)
#  username                           :string(255)      not null
#  email                              :string(255)
#  encrypted_password                 :string(255)      default(""), not null
#  legacy_encrypted_password          :string(255)
#  reset_password_token               :string(255)
#  reset_password_sent_at             :datetime
#  remember_created_at                :datetime
#  sign_in_count                      :integer          default(0)
#  current_sign_in_at                 :datetime
#  last_sign_in_at                    :datetime
#  current_sign_in_ip                 :string(255)
#  last_sign_in_ip                    :string(255)
#  password_salt                      :string(255)
#  given_name                         :string(255)
#  family_name                        :string(255)
#  display_name                       :string(255)
#  phone_number                       :string(255)
#  description                        :text(65535)
#  image_file_name                    :string(255)
#  image_content_type                 :string(255)
#  image_file_size                    :integer
#  image_updated_at                   :datetime
#  image_processing                   :boolean
#  facebook_id                        :string(255)
#  authentication_token               :string(255)
#  community_updates_last_sent_at     :datetime
#  min_days_between_community_updates :integer          default(1)
#  deleted                            :boolean          default(FALSE)
#  cloned_from                        :string(22)
#  google_oauth2_id                   :string(255)
#  linkedin_id                        :string(255)
#
# Indexes
#
#  index_people_on_authentication_token               (authentication_token)
#  index_people_on_community_id                       (community_id)
#  index_people_on_community_id_and_google_oauth2_id  (community_id,google_oauth2_id)
#  index_people_on_community_id_and_linkedin_id       (community_id,linkedin_id)
#  index_people_on_email                              (email) UNIQUE
#  index_people_on_facebook_id                        (facebook_id)
#  index_people_on_facebook_id_and_community_id       (facebook_id,community_id) UNIQUE
#  index_people_on_google_oauth2_id                   (google_oauth2_id)
#  index_people_on_id                                 (id)
#  index_people_on_linkedin_id                        (linkedin_id)
#  index_people_on_reset_password_token               (reset_password_token) UNIQUE
#  index_people_on_username                           (username)
#  index_people_on_username_and_community_id          (username,community_id) UNIQUE
#  index_people_on_uuid                               (uuid) UNIQUE
#

class PersonSerializer < ActiveModel::Serializer
   attributes :id, :created_at, :updated_at, :is_admin, :username, :email, :given_name, :family_name, :display_name, :phone_number, :description, :image_file_name, :image_content_type, :authentication_token, :deleted
end
