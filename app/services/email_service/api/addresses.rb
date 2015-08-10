module EmailService::API
  AddressStore = EmailService::Store::Address
  Synchronize = EmailService::SES::Synchronize

  class Addresses

    def initialize(default_sender:, ses_client: nil)
      @default_sender = default_sender
      @ses_client = ses_client
    end

    def get_sender(community_id:)
      sender = Maybe(community_id).map {
        AddressStore.get_latest_verified(community_id: community_id)
      }.map { |address|
        {
          type: :user_defined,
          display_format: to_format(name: address[:name], email: address[:email], quotes: false),
          smtp_format: to_format(name: address[:name], email: address[:email], quotes: true)
        }
      }.or_else(
        type: :default,
        display_format: @default_sender,
        smtp_format: @default_sender
      )

      Result::Success.new(sender)
    end

    def get_user_defined(community_id:)
      Maybe(AddressStore.get_latest(community_id: community_id)).map { |address|
        Result::Success.new(
          with_formats(address))
      }.or_else {
        Result::Error.new("Can not find for community_id: #{community_id}")
      }
    end

    def create(community_id:, address:)
      create_in_status = @ses_client ? :none : :verified

      address = with_formats(
        AddressStore.create(
        community_id: community_id,
        address: address.merge(verification_status: create_in_status)))

      if @ses_client
        enque_verification_request(community_id: address[:community_id], id: address[:id])
      end

      Result::Success.new(address)
    end

    def enque_verification_request(community_id:, id:)
      if @ses_client
        Maybe(AddressStore.get(community_id: community_id, id: id))
          .each do |address|
          @ses_client.verify_address(email: address[:email]).on_success do
            AddressStore.set_verification_requested(community_id: community_id, id: id)
          end
        end
      end
    end

    def enque_status_sync(community_id:, id:)
      if @ses_client
        Synchronize.run_single_synchronization!(
          community_id: community_id,
          id: id,
          ses_client: @ses_client)
      end
    end

    private

    def with_formats(address)
      address.merge(
        display_format: to_format(name: address[:name], email: address[:email], quotes: false),
        smtp_format: to_format(name: address[:name], email: address[:email], quotes: true))
    end

    def to_format(name: nil, email:, quotes:)
      if name.present?
        "#{quote(name, quotes)} <#{email}>"
      else
        email
      end
    end

    def quote(str, quotes)
      if quotes
        "\"#{str}\""
      else
        str
      end
    end
  end

end
