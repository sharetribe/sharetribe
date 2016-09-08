class ProcessImagesForListingCards < ActiveRecord::Migration

  def up
    select_values("SELECT id FROM listing_images").each { |id|
      Delayed::Job.enqueue(CreateSquareImagesJob.new(id), priority: 10, queue: "image_reprocess")
    }
  end

  def down
    # no op
  end
end
