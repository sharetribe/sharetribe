class CommunityJoinedJob < Struct.new(:person_id, :community_id) 
  
  # This before hook should be included in all Jobs to make sure that the service_name is 
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_host(host)
  end
  
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