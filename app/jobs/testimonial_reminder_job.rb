class TestimonialReminderJob < Struct.new(:conversation_id, :recipient_id, :community_id) 
  
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
    if !conversation.has_feedback_from_all_participants?
      participation = Participation.find_by_person_id_and_conversation_id(recipient_id, conversation_id)
      if participation.feedback_can_be_given?
        participation.update_attribute(:is_read, false)
        PersonMailer.send("testimonial_reminder", conversation, participation.person, community).deliver
      end
    end
  end
  
end