class MigrateOldFaviconsToPaperclip < ActiveRecord::Migration
 def self.up
    say "This migration will copy the existing favicons to paperclip."
    say "The old favicons images are NOT DELETED (for backup and safety).", true
    say "So you can delete them manually later.", true

    communities_with_favicons = Community.where("favicon_url is not null")
    say "Going through all #{communities_with_favicons.count} communities with old favicons now:"

     communities_with_favicons.each do |community|
       community.favicon = URI.parse(community.favicon_url)
       community.save!
       print "."
       STDOUT.flush
     end
     puts ""
  end
end
