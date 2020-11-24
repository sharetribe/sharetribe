class ChangeFeedbackToAdminFromSymbolToString < ActiveRecord::Migration
  def self.up
    Person.all.each do |person|
      person.preferences.delete(:email_about_accept_reminders)
      person.preferences["email_about_accept_reminders"] = true
      person.save
    end
  end

  def self.down
  end
end
