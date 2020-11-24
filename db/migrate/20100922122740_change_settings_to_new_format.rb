class ChangeSettingsToNewFormat < ActiveRecord::Migration
  class Setting < ApplicationRecord
  end
  def self.up
    change_column :people, :preferences, :text
    Person.all.each do |person|
      if settings = Setting.find_by_person_id(person.id)
        person.update_attributes({:preferences => {
          "email_about_new_messages" => (settings.email_when_new_message == 1),
          "email_about_new_comments_to_own_listing" => (settings.email_when_new_comment == 1),
          "email_when_conversation_accepted" => true,
          "email_when_conversation_rejected" => true,
          "email_when_new_friend_request" => (settings.email_when_new_friend_request == 1),
          "email_when_new_feedback_on_transaction" => (settings.email_when_new_comment_to_kassi_event == 1),
          "email_when_new_listing_from_friend" => (settings.email_when_new_listing_from_friend == 1)}})

      end
      print "."; STDOUT.flush
    end
    puts ""
  end

  def self.down
    change_column :people, :preferences, :string
  end
end
