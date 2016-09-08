class ProcessImagesForListingCards < ActiveRecord::Migration

  def up
    select_values("SELECT id FROM listing_images").each_slice(1000) { |ids|

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
      "(1, #{handler(id)}, NULL, NOW(), NOW(), NOW(), 'image_reprocess')"
    }.join(",")
  end

  def handler(id)
    "'--- !ruby/struct:CreateSquareImagesJob\nimage_id: #{id}\n'"
  end
end
