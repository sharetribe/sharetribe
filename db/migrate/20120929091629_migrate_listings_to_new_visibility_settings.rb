class MigrateListingsToNewVisibilitySettings < ActiveRecord::Migration
  def self.up
    Listing.all.each do |listing|
      case listing.visibility
      when "everybody"
        listing.update_attribute(:visibility, "all_communities")
        listing.update_attribute(:privacy, "public")
      when "communities"
        listing.update_attribute(:visibility, "all_communities")
      end
    end
  end

  def self.down
  end
end
