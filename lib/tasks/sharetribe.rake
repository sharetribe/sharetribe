namespace :sharetribe do

  namespace :community_updates do
    desc "Sends the community updates email to everyone who should receive it now"
    task :deliver => :environment do |t, args|
      CommunityMailer.deliver_community_updates
    end
  end

  desc "Cleans the auth_tokens table in the DB by deleting expired ones"
  task :delete_expired_auth_tokens => :environment do
    AuthToken.delete_expired
  end

  desc "Retries set express checkouts"
  task :retry_and_clean_paypal_tokens => :environment do
    Delayed::Job.enqueue(PaypalService::Jobs::RetryAndCleanTokens.new(1.hour.ago))
  end

  desc "Synchnorizes verified email address states from SES to local DB"
  task :synchronize_verified_with_ses => :environment do
    EmailService::API::Api.addresses.enqueue_batch_sync()
  end
end
