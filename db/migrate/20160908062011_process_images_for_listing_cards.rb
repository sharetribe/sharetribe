class ProcessImagesForListingCards < ActiveRecord::Migration

  def up
    select_values("SELECT id FROM listing_images").each_slice(1000) { |ids|
      Delayed::Job.enqueue(CreateSquareImagesJob.new(ids), priority: 10, queue: "image_reprocess")
    }
  end

  def down
    # no op
  end
end
