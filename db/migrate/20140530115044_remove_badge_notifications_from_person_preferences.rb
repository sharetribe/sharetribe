class RemoveBadgeNotificationsFromPersonPreferences < ActiveRecord::Migration
  def up
    Person.find_each do |person|
      if person.respond_to? :preferences
        person.update_attribute(:preferences, person.preferences.except("email_about_new_badges"))
      end
    end
  end

  def down
  end
end