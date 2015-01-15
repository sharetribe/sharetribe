class CreateMemberEmailBatchJob < Struct.new(:sender_id, :community_id, :subject, :content, :locale)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    current_community = Community.where(id: community_id).first

    current_community.members.find_in_batches(batch_size: 1000) do |member_group|
      Delayed::Job.transaction do
        member_group.each do |recipient|
          Delayed::Job.enqueue(CommunityMemberEmailSentJob.new(sender_id, recipient.id, community_id, subject, content, locale))
        end
      end
    end
  end

end
