require File.expand_path('../../migrate_helpers/logging_helpers', __FILE__)

class AddPaypalLogoSizeToCommunity < ActiveRecord::Migration
  include LoggingHelper

  def up
    with_logo { |logo|
      logo.reprocess! :paypal
    }
  end

  def down
    with_logo { |logo|
      logo.clear(:paypal)
      logo.save
    }
  end

  private

  def with_logo(&block)
    communities_with_logo = Community.where("wide_logo_file_name IS NOT NULL")

    progress = ProgressReporter.new(communities_with_logo.count, 20)

    communities_with_logo.find_each do |c|
      block.call(c.wide_logo)
      progress.next
      print_dot
    end
  end
end
