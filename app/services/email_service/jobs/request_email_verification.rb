module EmailService::Jobs
  class RequestEmailVerification < Struct.new(:community_id, :id)

    AddressStore = EmailService::Store::Address

    include DelayedAirbrakeNotification

    def perform
      Maybe(AddressStore.get(community_id: community_id, id: id))
        .each do |address|
        ses_client.verify_address(email: address[:email]).on_success do
          AddressStore.set_verification_requested(community_id: community_id, id: id)
        end
      end
    end

    private

    def ses_client
      EmailService::API::Api.ses_client
    end
  end
end
