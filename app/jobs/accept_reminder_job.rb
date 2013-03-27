class AcceptReminderJob < Struct.new(:conversation_id, :community_id, :number_of_reminders_sent)
  
  include DelayedAirbrakeNotification
  
  # This before hook should be included in all Jobs to make sure that the service_name is 
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end
  
  # Send the first reminder if 3 full days have passed since the offer/request without acceptance
  # or new messages. Send the second reminder if 7 full days have passed isince the first reminder
  # without acceptance or new messages. Don't send reminders after that.
  def perform
    conversation = Conversation.find(conversation_id)
    community = Community.find(community_id)
    
    if conversation.status.eql?("pending")
      actions = ApplicationHelper.prepare_transaction_reminder conversation, [3,7], {:number_of_reminders_sent => number_of_reminders_sent }
    
      if actions[:send_reminder]
        recipient = conversation.other_party(conversation.messages.last.sender)
        if recipient.should_receive?("email_about_accept_reminders")
          PersonMailer.accept_reminder(conversation, recipient, community).deliver
        end
      end

      if actions[:run_at]
        Delayed::Job.enqueue(AcceptReminderJob.new(conversation.id, community.id, actions[:number_of_reminders_sent]), :priority => 0, :run_at => actions[:run_at])
      end
      
    end  
      
  end
  
end