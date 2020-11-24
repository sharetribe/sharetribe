require File.expand_path('../../migrate_helpers/logging_helpers', __FILE__)

class ReprocessCommunityLogosToHighres < ActiveRecord::Migration
  include LoggingHelper

  def up
    communities_with_logos = Community.where("logo_file_name IS NOT NULL")
    progress = ProgressReporter.new(communities_with_logos.count, 20)

    communities_with_logos.each do |community|
      begin
        community.logo.reprocess_without_delay!
      rescue Errno::ENOENT => e
        puts "Didn't find the logo file for this community, skipping."
      end
      progress.next
    end

    communities_with_wide_logos = Community.where("wide_logo_file_name IS NOT NULL")
    progress = ProgressReporter.new(communities_with_wide_logos.count, 20)

    communities_with_wide_logos.each do |community|
      begin
        community.wide_logo.reprocess_without_delay!
      rescue Errno::ENOENT => e
        puts "Didn't find the logo file for this community, skipping."
      end
      progress.next
    end
  end
end