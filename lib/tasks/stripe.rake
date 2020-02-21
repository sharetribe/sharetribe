namespace :stripe do
  desc 'Enable stripe'
  task enable: :environment do
    community_id = Community.find_by_ident('donalo').id

    TransactionService::API::Api.processes.create(
      community_id: community_id,
      process: :preauthorize,
      author_is_seller: true
    )
    TransactionService::API::Api.settings.provision(
      community_id: community_id,
      payment_gateway: :stripe,
      payment_process: :preauthorize,
      active: true
    )
  end
end
