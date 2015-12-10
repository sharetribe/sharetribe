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
#  status_ids                    :text
#
# Indexes
#
#  index_person_background_checks_on_background_check_container_id  (background_check_container_id)
#  index_person_background_checks_on_person_id                      (person_id)
#

class PersonBackgroundCheck < ActiveRecord::Base
  attr_accessible :background_check_container_id, :document, :person_id, :value, :status_ids
  serialize :status_ids, Array
  belongs_to :person
  belongs_to :background_check_container

  has_attached_file :document,
                    :url => "/:class/:id/:filename",
                    :path => "public/:class/:id/:filename"
  
  validates_attachment_content_type :document,
                                    :content_type => ["application/pdf", "application/doc", "application/download", "image/jpeg", "image/png", "image/gif",
                                      "image/pjpeg", "image/x-png"] #the two last types are sent by IE.
  validates_attachment_size :document, :less_than => 3.megabytes
end
