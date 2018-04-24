# == Schema Information
#
# Table name: export_task_results
#
#  id                :integer          not null, primary key
#  status            :string(255)
#  token             :string(255)
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer
#  file_updated_at   :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class ExportTaskResult < ApplicationRecord
  attr_accessor :original_filename, :original_extname
  has_attached_file :file, s3_headers: lambda { |record|
    {
      'Content-Type' => "text/#{record.original_extname}",
      'Content-Disposition' => "attachment; filename=#{record.original_filename}",
    }
  },
                           path: "file-exports/:class/:attachment/:id/:filename",
                           s3_permissions: :private

  do_not_validate_attachment_file_type :file

  STATUSES = ['pending', 'started', 'finished']
  AWS_S3_URL_EXPIRES_SECONDS = 10

  before_create :set_token_and_status

  def set_token_and_status
    self.token  = SecureRandom.urlsafe_base64
    self.status = 'pending'
  end
end
