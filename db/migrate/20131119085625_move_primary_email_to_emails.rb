require File.expand_path('../../migrate_helpers/logging_helpers', __FILE__)

class MovePrimaryEmailToEmails < ActiveRecord::Migration
  include LoggingHelper

  def up
    Person.all.each do |person|
      primary_email = person.email
      email_from_additionals = Email.find_by_address(primary_email)

      if !email_from_additionals then
        # Create new email in emails table
        Email.create(:person => person, :address => primary_email, :confirmed_at => person.confirmed_at, :send_notifications => true)
      else
        # Address exists in emails table
        # Mark it as "primary" i.e. send notifications to it
        email_from_additionals.send_notifications = true
      end

      print_dot
    end
    puts ""
  end

  def down
    Email.destroy_all(:send_notifications => true)
  end
end
