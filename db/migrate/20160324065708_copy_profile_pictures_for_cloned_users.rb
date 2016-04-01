class CopyProfilePicturesForClonedUsers < ActiveRecord::Migration

  class Person < ActiveRecord::Base
  end

  def up
    Person.where("cloned_from IS NOT NULL").pluck(:id).each { |person_id|
      Delayed::Job.enqueue(CopyProfilePictureJob.new(person_id), priority: 10)
    }
  end

  def down
    # Don't delete the cloned images.
    # The problem is that we can't know whether the current image is a cloned image
    # or actually an image that the user uploaded there after the up migration
    # was run
  end
end
