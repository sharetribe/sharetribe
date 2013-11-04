class NewCoverPhoto < ActiveRecord::Migration
  say "This migration will reprocess the cover photo to 1920x450 aspect ratio for #{Community.count} communities"

  def up
    Community.all.each do |community|
      community.cover_photo.reprocess! :hd_header
      print "."
      STDOUT.flush
    end
    puts ""
  end
  
end
