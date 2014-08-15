require File.expand_path('../../migrate_helpers/logging_helpers', __FILE__)

class InitializeCategoryUrls < ActiveRecord::Migration
  include LoggingHelper

  def up
    Category.reset_column_information

    progress = ProgressReporter.new(Community.count, 100)

    Community.find_each do |community|
      community.categories.each do |category|
        category.ensure_unique_url
        category.save!
      end

      progress.next
      print_dot
    end
  end

  def down
  end
end
