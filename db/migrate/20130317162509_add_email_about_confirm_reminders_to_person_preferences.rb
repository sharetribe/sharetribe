class AddEmailAboutConfirmRemindersToPersonPreferences < ActiveRecord::Migration
  def up
    Person.find_each do |person|
      person.preferences["email_about_confirm_reminders"] = true
      person.save
    end
  end
  
  def down
    Person.find_each do |person|
      person.preferences["email_about_confirm_reminders"] = nil
      person.save
    end
  end
end
