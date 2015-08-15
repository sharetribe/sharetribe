module EmailService::Jobs
  class SingleSync < Struct.new(:community_id, :id)

    Synchronize = EmailService::SES::Synchronize

    include DelayedAirbrakeNotification

    def perform
      Synchronize.run_single_synchronization!(
        community_id: community_id,
        id: id,
        ses_client: ses_client)
    end


    private

    def ses_client
      EmailService::API::Api.ses_client
    end
  end
end
