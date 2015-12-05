# == Schema Information
#
# Table name: person_background_checks
#
#  id                            :integer          not null, primary key
#  person_id                     :string(255)
#  background_check_container_id :integer
#  value                         :text
#  document_file_name            :string(255)
#  document_content_type         :string(255)
#  document_file_size            :integer
#  document_updated_at           :datetime
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_person_background_checks_on_background_check_container_id  (background_check_container_id)
#  index_person_background_checks_on_person_id                      (person_id)
#

class PersonBackgroundCheck < ActiveRecord::Base
  attr_accessible :background_check_container_id, :document, :person_id, :value

  belongs_to :person
  belongs_to :background_check_container

  has_attached_file :document, :styles => {
                      :medium => "288x288#",
                      :small => "108x108#",
                      :thumb => "48x48#",
                      :original => "600x800>"},
                    :default_url => ActionController::Base.helpers.asset_path("/assets/profile_image/:style/missing.png", :digest => true)
  process_in_background :document

  #validates_attachment_presence :image
  validates_attachment_size :document, :less_than => 5.megabytes
  validates_attachment_content_type :document,
                                    :content_type => ["image/jpeg", "image/png", "image/gif",
                                      "image/pjpeg", "image/x-png"] #the two last types are sent by IE.
end
