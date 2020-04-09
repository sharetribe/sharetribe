class AddSettingsToExistingPeople < ActiveRecord::Migration[5.2]
def self.up
    Person.find(:all).each do |person| 
      person.settings = Settings.create
    end  
  end

  def self.down
    Person.find(:all).each do |person| 
      person.settings = nil
    end
  end
end
