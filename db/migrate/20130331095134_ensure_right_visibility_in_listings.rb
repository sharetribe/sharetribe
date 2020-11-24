class EnsureRightVisibilityInListings < ActiveRecord::Migration
  def up
    # This operation is actually done once already, but as there was no validation for the visiblity
    # There may have been some done via API with old visibility
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

  def down
  end
end
