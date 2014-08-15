require File.expand_path('../../migrate_helpers/logging_helpers', __FILE__)

class InitializeTransactionTypeUrls < ActiveRecord::Migration
  include LoggingHelper

  def up
    TransactionType.reset_column_information

    progress = ProgressReporter.new(Community.count, 100)

    Community.find_each do |community|
      community.transaction_types.each do |transaction_type|
        transaction_type.ensure_unique_url
        transaction_type.save!
      end

      progress.next
      print_dot
    end
  end

  def down
  end
end
