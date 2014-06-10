require File.expand_path('../../migrate_helpers/logging_helpers', __FILE__)

class PopulateParticipationStarter < ActiveRecord::Migration
  include LoggingHelper

  def up
    Participation.reset_column_information
    Conversation.reset_column_information
    progress = ProgressReporter.new(Conversation.count, 1000)

    Conversation.find_each do |conversation|
      first_message_sender = Maybe(conversation).messages.map { |ms| ms.first }.sender

      starter_participation = first_message_sender.flat_map do |starter|
        Maybe(conversation).participations.flat_map do |participations|
          find_starter_participation(participations, starter)
        end
      end

      starter_participation.each do |starter|
        starter.update_attribute(:is_starter, true)
      end

      # Log
      progress.next
      print_dot
    end
  end

  # Give participations and first_message_sender, get back Maybe
  def find_starter_participation(all_participations, starter)
    Maybe(all_participations).map do |participations|
      participations.find do |participation|
        participation.person == starter
      end
    end
  end
end