require File.expand_path('../../migrate_helpers/logging_helpers', __FILE__)

class DowncaseAllEmails < ActiveRecord::Migration
  include LoggingHelper
  
  def up
    Email.find_each do |email|
      email.update_column(:address, email.address.downcase)
      print_dot
    end
  end

  def down
  end
end
