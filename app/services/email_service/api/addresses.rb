module EmailService::API
  AddressStore = EmailService::Store::Address

  class Addresses

    def initialize(default_sender:)
      @default_sender = default_sender
    end

    def get_sender(community_id:)
      sender = Maybe(community_id).map {
        AddressStore.get(community_id: community_id)
      }.map { |address|
        {
          formatted: to_format(name: address[:name], email: address[:email], quotes: false),
          smtp_formatted: to_format(name: address[:name], email: address[:email], quotes: true)
        }
      }.or_else(formatted: @default_sender, smtp_formatted: @default_sender)

      Result::Success.new(sender)
    end

    def get_user_defined(community_id:)
      Result::Success.new(AddressStore.get_all(community_id: community_id).map { |address| with_formatted(address) })
    end

    # TODO get_user_defined

    def create(community_id:, opts:)
      Result::Success.new(
        with_formatted(
          AddressStore.create(
          community_id: community_id,
          opts: opts)))
    end

    private

    def with_formatted(address)
      address.merge(
        formatted: to_format(name: address[:name], email: address[:email], quotes: false),
        smtp_formatted: to_format(name: address[:name], email: address[:email], quotes: true))
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
