class AddEmailAboutAcceptReminders < ActiveRecord::Migration
  def self.up
    # Note: the key should be a string instead of a symbol. This
    # is fixed in a later migration, do not use this code as such!
    Person.all.each do |person|
      person.update_attribute(:preferences, person.preferences.merge({:email_about_accept_reminders => true}))
    end
  end

  def self.down
  end
end
