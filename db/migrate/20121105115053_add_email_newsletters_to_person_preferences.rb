class AddEmailNewslettersToPersonPreferences < ActiveRecord::Migration
  def self.up
    Person.all.each do |person|
      if person.preferences.nil?
        person.set_default_preferences
      end
      p = person.preferences
      p.delete("temp") # remove old temp value that might still be in some databases
      p.merge!({"email_newsletters" => true})
      person.update_attribute(:preferences, p)
    end
  end

  def self.down
    Person.all.each do |person|
      p = person.preferences
      p.delete("email_newsletters")
      person.update_attribute(:preferences, p)
    end
  end
end
