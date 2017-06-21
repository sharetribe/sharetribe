class CopyProfilePicturesForClonedUsers < ActiveRecord::Migration

  class Person < ApplicationRecord
  end

  def up
    Person.where("cloned_from IS NOT NULL").pluck(:id).each { |person_id|
      # This job expects that the Person can be found from the database
      # when the job is executed
      Delayed::Job.enqueue(CopyProfilePictureJob.new(person_id), priority: 10)
    }
  end

  def down
    Person.where("cloned_from IS NOT NULL").pluck(:id, :image_file_name).each { |(person_id, image_file_name)|
      if image_file_name.present?
        # This job does not expect that the Person can be found from the database
        # when the job is executed
        Delayed::Job.enqueue(DeleteProfilePictureJob.new(person_id, image_file_name), priority: 11)
      end
    }

    Person
      .where("cloned_from IS NOT NULL")
      .update_all(
        image_file_name: nil,
        image_content_type: nil,
        image_file_size: nil,
        image_updated_at: nil,
        image_processing: nil
      )
  end
end
