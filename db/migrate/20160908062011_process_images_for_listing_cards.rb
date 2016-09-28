class ProcessImagesForListingCards < ActiveRecord::Migration

  def up
    # Select listing images that are related to listings
    # that are not closed. For every 1000 of those images
    # create a delayed job that creates square versions
    # of the images.

    select_values("
      SELECT li.id
      FROM listing_images AS li, listings AS l
      WHERE 1=1
        AND li.listing_id = l.id
        AND l.open = 1
        AND l.valid_until >= NOW()
    ").each_slice(1000) { |ids|

      exec_insert("INSERT INTO delayed_jobs
                  (priority, handler, last_error, run_at, created_at, updated_at, queue)
                  VALUES #{values(ids)}", "create_delayed_jobs", [])
    }
  end

  def down
    # no op
  end

  def values(ids)
    ids.map { |id|
      "(11, '#{handler(id)}', NULL, NOW(), NOW(), NOW(), 'default')"
    }.join(",")
  end

  def handler(id)
    CreateSquareImagesJob.new(id).to_yaml
  end

end
