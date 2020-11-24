module AttachmentDestroyer
  extend ActiveSupport::Concern

  # does not delete files on S3
  def attachments_destroyer=(data)
    data.each do |attachment_name|
      attachment = send(attachment_name)
      attachment.destroy
    end
  end
end
