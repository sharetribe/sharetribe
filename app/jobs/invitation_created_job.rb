class InvitationCreatedJob < Struct.new(:invitation_id, :community_id)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    community = Community.find(community_id)
    ApplicationHelper.store_community_service_name_to_thread(community.name(community.default_locale))
  end

  def perform
    invitation = Invitation.find(invitation_id)
    MailCarrier.deliver_now(PersonMailer.invitation_to_kassi(invitation))
  end

end
