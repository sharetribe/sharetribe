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
        to_smtp_format(name: address[:name], email: address[:email])
      }.or_else(@default_sender)

      Result::Success.new(sender)
    end

    # TODO get_user_defined

    def create(community_id:, opts:)
      Result::Success.new(
        with_smtp_format(
          AddressStore.create(
          community_id: community_id,
          opts: opts)))
    end

    private

    def with_smtp_format(address)
      address.merge(smtp_format: to_smtp_format(name: address[:name], email: address[:email]))
    end

    def to_smtp_format(name: nil, email:)
      if name.present?
        "\"#{name}\" <#{email}>"
      else
        email
      end
    end
  end

end
