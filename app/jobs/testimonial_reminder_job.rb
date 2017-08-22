#reminder is sent to both parties, no need for recipient id anymore
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
    return if Maybe(::PlanService::API::Api.plans.get_current(community_id: community_id).data)[:expired].or_else(false)

    transaction = Transaction.find(conversation_id)
    community = Community.find(community_id)

    if should_send_author_reminder?(transaction)
      MailCarrier.deliver_now(PersonMailer.send("testimonial_reminder", transaction, transaction.author, community))
    end

    if should_send_starter_reminder?(transaction)
      MailCarrier.deliver_now(PersonMailer.send("testimonial_reminder", transaction, transaction.starter, community))
    end
  end

  def should_send_author_reminder?(transaction)
    transaction.testimonial_from_author.nil? &&
      !transaction.author_skipped_feedback &&
      transaction.author.should_receive?("email_about_testimonial_reminders")
  end

  def should_send_starter_reminder?(transaction)
    transaction.testimonial_from_starter.nil? &&
      !transaction.starter_skipped_feedback &&
      transaction.starter.should_receive?("email_about_testimonial_reminders")
  end

end
