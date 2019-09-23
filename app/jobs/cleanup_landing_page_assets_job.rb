class CleanupLandingPageAssetsJob < Struct.new(:community_id)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have community_id parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    community = Community.find(community_id)
    existing_asset_ids = LandingPageVersion.where(community_id: community_id).map do |lpv|
      (lpv.parsed_content['assets'] || []).map{|asset| asset['asset_id']}
    end.flatten.compact.uniq
    community.landing_page_assets.where.not(id: existing_asset_ids).each do |attachment|
      attachment.purge
    end
  end

end
