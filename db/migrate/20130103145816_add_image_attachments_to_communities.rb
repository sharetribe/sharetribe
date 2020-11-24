class AddImageAttachmentsToCommunities < ActiveRecord::Migration
  def change
    add_attachment :communities, :logo
    add_attachment :communities, :cover_photo
  end
end
