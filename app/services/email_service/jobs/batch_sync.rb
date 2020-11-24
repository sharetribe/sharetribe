module EmailService::Jobs
  class BatchSync

    Synchronize = EmailService::SES::Synchronize

    include DelayedAirbrakeNotification

    def perform
      Synchronize.run_batch_synchronization!(ses_client: ses_client)
    end


    private

    def ses_client
      EmailService::API::Api.ses_client
    end
  end
end
