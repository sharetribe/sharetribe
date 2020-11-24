class AddDefaultPreferencesToPeople < ActiveRecord::Migration
  def self.up
    Person.all.each do |person| 
      person.update_attributes(:preferences => { "email_about_new_comments_to_own_listing" => "true", "email_about_new_messages" => "true"})
    end  
  end

  def self.down
  end
end
