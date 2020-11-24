module EmailService::Jobs
  class RequestEmailVerification < Struct.new(:community_id, :id)

    AddressStore = EmailService::Store::Address

    include DelayedAirbrakeNotification

    def perform
      Maybe(AddressStore.get(community_id: community_id, id: id))
        .each do |address|
        ses_client.verify_address(email: address[:email]).on_success do

          # If the address being verified for the first time...
          if address[:verification_status] == :none
            set_notification_topics(address[:email])
          end

          AddressStore.set_verification_requested(community_id: community_id, id: id)
        end
      end
    end

    private

    # Direct bounces and complaints to an SNS topic (configured at
    # ses_client) and disable them from being forwarded to the sender
    # email.
    def set_notification_topics(email)
      ses_client.set_notification_topic(email: email, type: :bounce).on_success do
        ses_client.set_notification_topic(email: email, type: :complaint).on_success do
          ses_client.disable_email_forwarding(email: email)
        end
      end
    end

    def ses_client
      EmailService::API::Api.ses_client
    end
  end
end
