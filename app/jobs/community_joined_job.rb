class CommunityJoinedJob < Struct.new(:person_id, :community_id) 
  
  def perform
    current_user = Person.find(person_id)
    current_community = Community.find(community_id)
    current_user.listings.each do |listing|
      if ["this_community", "everybody"].include?(listing.visibility) && !listing.communities.include?(current_community)
        listing.communities << current_community
      end
    end
  end
  
end