class AddAttachmentDimensions < ActiveRecord::Migration
  say "This migration adds fields width and height to listing images table"

  def log(i, count, message)
    n = if count < 10 then 2
        elsif count < 100 then 10
        else 100
        end

    if i > 0 && i % n === 0 then
      puts "\n[#{i}/#{count}] #{message}\n"
    end
  end

  def up
    add_column :listing_images, :width, :int
    add_column :listing_images, :height, :int

    # Let's us use the newly added width/height
    ListingImage.reset_column_information

    begin
      count = Listing.count

      puts "Start processing #{count} listings"

      Listing.order("id DESC").all.each_with_index do |listing, i|
        log(i, count, "Processed listing which was created at #{listing.created_at}")

        listing.listing_images.each do |listing_image|
          # Before save extracts dimensions
          begin
            listing_image.save
          rescue Paperclip::Errors::NotIdentifiedByImageMagickError
            puts "COULD NOT RETRIVE DIMENSIONS FOR ListingImage (id: #{listing_image.id}) SKIPPING!"
          end
          print "."
          STDOUT.flush
        end
      end
      puts ""
    rescue Exception => e
      puts "Migration failed, going down\n"
      self.down

      raise e
    end
  end

  def down
    remove_column :listing_images, :width
    remove_column :listing_images, :height
  end
end
