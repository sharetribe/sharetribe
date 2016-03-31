require File.expand_path('../../migrate_helpers/logging_helpers', __FILE__)

class CopyProfilePicturesForClonedUsers < ActiveRecord::Migration
  include LoggingHelper

  def up
    cloned_users = Person.where("cloned_from IS NOT NULL")

    progress = ProgressReporter.new(cloned_users.count, 100)

    cloned_users.each { |cloned_user|
      cloned_from_user = Person.find_by(id: cloned_user.cloned_from)

      cloned_user.image = cloned_from_user.image
      cloned_user.save!

      # Print progress
      progress.next
      print_dot
    }
  end

  def down
    cloned_users = Person.where("cloned_from IS NOT NULL")

    progress = ProgressReporter.new(cloned_users.count, 100)

    cloned_users.each { |cloned_user|
      cloned_user.image.destroy
      cloned_user.save!

      # Print progress
      progress.next
      print_dot
    }
  end
end
