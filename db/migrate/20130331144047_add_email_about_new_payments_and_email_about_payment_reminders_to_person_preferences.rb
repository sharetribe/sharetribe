class AddEmailAboutNewPaymentsAndEmailAboutPaymentRemindersToPersonPreferences < ActiveRecord::Migration[5.2]
def up
    Person.find_each do |person|
      person.preferences["email_about_new_payments"] = true
      person.preferences["email_about_payment_reminders"] = true
      person.save
    end
  end
  
  def down
    Person.find_each do |person|
      person.preferences["email_about_new_payments"] = nil
      person.preferences["email_about_confirm_reminders"] = nil
      person.save
    end
  end
end
