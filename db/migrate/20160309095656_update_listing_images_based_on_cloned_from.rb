class UpdateListingImagesBasedOnClonedFrom < ActiveRecord::Migration
  def up
    execute("
        UPDATE listing_images, listings
        SET listing_images.author_id = listings.author_id
        WHERE
          listing_images.listing_id = listings.id
      ")
  end

  def down
    execute("
      UPDATE listing_images AS li, people as p
      SET li.author_id = p.cloned_from
      WHERE
        li.author_id = p.id AND
        p.cloned_from IS NOT NULL
    ")
  end
end
