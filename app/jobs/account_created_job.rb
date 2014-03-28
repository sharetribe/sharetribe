class AccountCreatedJob < Struct.new(:person_id, :community_id, :email)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    # These things happen now in community_joined. But keeping this here, in case we add tasks to account creation later.
    # community = Community.find(community_id)
    # person = Person.find(person_id)
    # PersonMailer.new_member_notification(person, community.domain, email).deliver if community.email_admins_about_new_members?
    # EventFeedEvent.create(:person1_id => person.id, :community_id => community.id, :category => "join")
  end

end
