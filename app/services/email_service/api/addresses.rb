module EmailService::API
  AddressStore = EmailService::Store::Address

  class Addresses

    def initialize(default_sender:)
      @default_sender = default_sender
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
      Result::Success.new(
        with_formats(
          AddressStore.create(
          community_id: community_id,
          address: {verification_status: :none}.merge(address))))
    end

    def enque_status_sync
      # TODO Implement this
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
