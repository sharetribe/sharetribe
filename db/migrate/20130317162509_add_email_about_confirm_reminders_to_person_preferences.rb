class AddEmailAboutConfirmRemindersToPersonPreferences < ActiveRecord::Migration[5.2]
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
