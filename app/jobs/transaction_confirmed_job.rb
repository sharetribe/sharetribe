class TransactionConfirmedJob < Struct.new(:conversation_id, :community_id)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    begin
      conversation = Conversation.find(conversation_id)
      community = Community.find(community_id)
      PersonMailer.transaction_confirmed(conversation, community).deliver
      conversation.participations.each do |participation|
        [3, 10].each do |send_interval|
          Delayed::Job.enqueue(TestimonialReminderJob.new(conversation.id, participation.person.id, community.id), :priority => 10, :run_at => send_interval.days.from_now)
        end
      end
    rescue => ex
      puts ex.message
      puts ex.backtrace.join("\n")
    end
  end

end
