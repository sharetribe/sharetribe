require File.expand_path('../../migrate_helpers/logging_helpers', __FILE__)

class RemoveBadgeNotificationsFromPersonPreferences < ActiveRecord::Migration
  include LoggingHelper

  def up
    person_with_preferences do |person|
      person.update_attribute(:preferences, person.preferences.except("email_about_new_badges"))
    end
  end

  def down
    person_with_preferences do |person|
      person.update_attribute(:preferences, {"email_about_new_badges" => false}.merge(person.preferences))
    end
  end

  def person_with_preferences(&block)
    progress = ProgressReporter.new(Person.count, 100)

    Person.find_each do |person|
      if person.respond_to? :preferences
        block.call(person)
      end

      progress.next
      print_dot
    end
  end
end