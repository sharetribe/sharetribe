class MigrateListingImagesToPaperClip < ActiveRecord::Migration
  def self.up
    say "This migration will copy the existing images to paperclip."
    say "The old listing_images directory IS NOT DELETED (for backup and safety).", true
    say "So you can delete it manually later.", true
    say "Going through all #{Listing.count} listings now:"
     Listing.all.each do |listing|
       if File.exists?("public/listing_images/#{listing.id.to_s}.png")
         listing_image = ListingImage.new(:image => File.new("public/listing_images/#{listing.id.to_s}.png"))
         listing.listing_images = [listing_image]
       end
       print "."
       STDOUT.flush
     end
     puts ""
  end

  def self.down
    raise  ActiveRecord::IrreversibleMigration, "Deletion of the paperclip image files is not implemented.\
       If you wish to rollback, you can quite safely remove this IrreversibleMigration."
  end
end
