class TestimonialReminderJob < Struct.new(:conversation_id, :host) 
  
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
    if conversation.status.eql?("accepted") && !conversation.has_feedback_from_all_participants?
      conversation.participants.each do |participant|
        participation = Participation.find_by_person_id_and_conversation_id(participant.id, conversation.id)
        participation.send_testimonial_reminder(host)
      end
      Delayed::Job.enqueue(TestimonialReminderJob.new(conversation.id, community), :priority => 0, :run_at => 1.month.from_now)
    end
  end
  
end