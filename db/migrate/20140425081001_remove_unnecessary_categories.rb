require File.expand_path('../../migrate_helpers/logging_helpers', __FILE__)

class RemoveUnnecessaryCategories < ActiveRecord::Migration
  include LoggingHelper

  def up
    community_id_null = Category.where("community_id IS NULL")
    orphan_translations = community_id_null.collect(&:translations).flatten

    puts "Found #{community_id_null.count} categories without community id, deleting them..."
    puts "Found #{orphan_translations.count} category translations that will become orphan, deleting them..."

    community_id_null.delete_all
    orphan_translations.each do |translation|
      translation.destroy
      print_dot
    end
  end
end