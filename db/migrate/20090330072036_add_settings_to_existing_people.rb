class AddSettingsToExistingPeople < ActiveRecord::Migration
  def self.up
    if Person.any?
      Person.find(:all).each do |person|
        person.settings = Settings.create
      end
    end
  end

  def self.down
    if Person.any?
      Person.find(:all).each do |person|
        person.settings = nil
      end
    end
  end
end
