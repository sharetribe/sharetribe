class AddEmailAboutNewReceivedTestimonials < ActiveRecord::Migration[5.2]
def self.up
    Person.all.each do |person|
      person.update_attribute(:preferences, person.preferences.merge({:email_about_new_received_testimonials => true}))
    end
  end

  def self.down
  end
end
