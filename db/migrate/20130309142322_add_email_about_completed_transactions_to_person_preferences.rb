class AddEmailAboutCompletedTransactionsToPersonPreferences < ActiveRecord::Migration
  def up
    Person.find_each do |person|
      person.preferences["email_about_completed_transactions"] = true
      person.save
    end
  end
  
  def down
    Person.find_each do |person|
      person.preferences["email_about_completed_transactions"] = nil
      person.save
    end
  end
end
