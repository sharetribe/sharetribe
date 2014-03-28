class PaymentCreatedJob < Struct.new(:payment_id, :community_id)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have community_id parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    begin
      payment = Payment.find(payment_id)
      community = Community.find(community_id)
      payment_mail_creator = PaymentMailCreator.new(payment, community)

      if payment.recipient.should_receive?("email_about_new_payments")
        payment_mail_creator.new_payment.deliver
      end
      payment_mail_creator.receipt_to_payer.deliver
    rescue => ex
      puts ex.message
      puts ex.backtrace.join("\n")
    end
  end

end
