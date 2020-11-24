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
        Result::Error.new("Cannot find for community_id: #{community_id}")
      }
    end

    def update(community_id:, id:, name:)
      Result::Success.new(AddressStore.update(community_id: community_id, id: id, name: name))
    end

    def create(community_id:, address:)
      lowercase_email = Maybe(address)[:email].downcase.or_else(nil)

      valid_email_format?(lowercase_email).on_error {
        return Result::Error.new("Incorrect email format: '#{lowercase_email}'", error_code: :invalid_email, email: lowercase_email)
      }

      valid_email_domain?(lowercase_email).on_error { |error_msg, data|
        return Result::Error.new("Disallowed email provider: '#{address[:domain]}'", error_code: :invalid_domain, email: lowercase_email, domain: data[:domain])
      }

      create_in_status = @ses_client ? :none : :verified

      created_address = AddressStore.create(
        community_id: community_id,
        address: address.merge(
          verification_status: create_in_status,
          email: lowercase_email))

      if @ses_client
        enqueue_verification_request(community_id: created_address[:community_id], id: created_address[:id])
      end

      Result::Success.new(with_formats(created_address))
    end

    def enqueue_verification_request(community_id:, id:)
      if @ses_client
        Delayed::Job.enqueue(
          EmailService::Jobs::RequestEmailVerification.new(community_id, id),
          priority: 2
        )
      end
    end

    def enqueue_status_sync(community_id:, id:)
      if @ses_client
        Delayed::Job.enqueue(
          EmailService::Jobs::SingleSync.new(community_id, id),
          priority: 0
        )
      end
    end

    def enqueue_batch_sync
      if @ses_client
        Delayed::Job.enqueue(EmailService::Jobs::BatchSync.new)
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
        # Use inspect to add quotes.
        # Accoring to Ruby docs, inspect:
        # "Returns a printable version of str, surrounded by quote marks, with special characters escaped"
        str.inspect
      else
        str
      end
    end

    def valid_email_format?(email)
      if email
        email_regexp =
          %r{\A[A-Z0-9._%\-\+\~\/]+@([A-Z0-9-]+\.)+[A-Z]+\z}i # Same regexp as in Email model
        email_regexp.match(email).present? ? Result::Success.new() : Result::Error.new("invalid email format")
      else
        Result::Error.new("No email address")
      end
    end

    def valid_email_domain?(email)
      if @ses_client
        fulldomain = email.split("@").second

        fulldomain.include?("yahoo.") ? Result::Error.new("disallowed domain", domain: fulldomain) : Result::Success.new()
      else
        Result::Success.new()
      end
    end
  end

end
