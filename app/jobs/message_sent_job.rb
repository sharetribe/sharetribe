class MessageSentJob < Struct.new(:conversation_id, :last_message_id, :host)
  
  # This before hook should be included in all Jobs to make sure that the service_name is 
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_host(host)
  end
  
  def perform
    conversation = Conversation.find(conversation_id)
    conversation.send_email_to_participants(host)
    Delayed::Job.enqueue(AcceptReminderJob.new(conversation.id, last_message_id, host), :priority => 0, :run_at => 1.week.from_now) unless conversation.status.eql?("free")
  end
  
end