require File.expand_path('../../migrate_helpers/logging_helpers', __FILE__)

class AddNewLogoStyleAppleTouch < ActiveRecord::Migration
  include LoggingHelper

  def up
    communities_with_logos = Community.where("logo_file_name IS NOT NULL")
    progress = ProgressReporter.new(communities_with_logos.count, 20)

    communities_with_logos.each do |community|
      community.logo.reprocess_without_delay!
      progress.next
    end
  end
end