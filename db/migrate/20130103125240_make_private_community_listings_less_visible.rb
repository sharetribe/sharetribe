class MakePrivateCommunityListingsLessVisible < ActiveRecord::Migration
  def up
    Community.all.each do |community|
      if community.private
        community.listings.each do |listing|
          listing.update_column(:privacy, "private")
          if listing.communities.size == 1
            listing.update_column(:visibility, "this_community")
          end
        end
      end
    end
  end

  def down
    # nothing can be done here but it shouldn't be dangerous, so no need for irreversible migration here
  end
end
