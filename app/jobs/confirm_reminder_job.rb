class ConfirmReminderJob < Struct.new(:conversation_id, :recipient_id, :community_id, :number_of_reminders_sent)
  
  include DelayedAirbrakeNotification
  
  # This before hook should be included in all Jobs to make sure that the service_name is 
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end
  
  def perform
    conversation = Conversation.find(conversation_id)
    community = Community.find(community_id)
    if conversation.status.eql?("accepted") || conversation.status.eql?("paid")
      PersonMailer.send("confirm_reminder", conversation, conversation.requester, community).deliver
    end
  end
  
end