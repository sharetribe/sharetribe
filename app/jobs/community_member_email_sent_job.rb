class CommunityMemberEmailSentJob < Struct.new(:sender_id, :recipient_id, :community_id, :content, :locale, :test_to_yourself)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    sender = Person.where(id: sender_id).first
    recipient = Person.where(id: recipient_id).first
    community = Community.where(id: community_id).first
    PersonMailer.community_member_email_from_admin(sender, recipient, community, content, locale, test_to_yourself)
  end

end
