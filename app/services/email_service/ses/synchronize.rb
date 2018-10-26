module EmailService::SES::Synchronize

  AddressStore = EmailService::Store::Address

  BATCH_SIZE = 100
  SES_WAIT_TIME_SECONDS = 1

  module_function

  def run_batch_synchronization!(ses_client:)
    offset = 0
    addresses = AddressStore.load_all(limit: BATCH_SIZE, offset: offset)

    while addresses.present?
      verified_addresses = []
      result = ses_client.get_identity_verification_attributes(emails: addresses.map { |a| a[:email] })
      if result.success
        verification_attributes = result.data
        addresses.each do |address|
          email = address[:email]
          status = verification_attributes[email]
          if status && status[:verification_status] == 'Success'
            verified_addresses.push(email)
          end
        end
      end

      update_statuses(build_sync_updates(addresses, verified_addresses))

      offset += BATCH_SIZE
      addresses = AddressStore.load_all(limit: BATCH_SIZE, offset: offset)
      # from SES get_identity_verification_attributes documentation
      # This operation is throttled at one request per second
      sleep SES_WAIT_TIME_SECONDS
    end
  end

  def run_single_synchronization!(community_id:, id:, ses_client:)
    address = AddressStore.get(community_id: community_id, id: id)
    email = address[:email]
    if email_verified?(ses_client, email)
      update_statuses(build_sync_updates([address],[email]))
    end
  end

  def build_sync_updates(addresses, verified_addresses)
    vaddrs = verified_addresses.to_set
    updates = { verified: [], expired: [], touch: [], none: [] }

    addresses.each do |a|
      updates[classify(a, vaddrs)].push(a[:id])
    end

    updates
  end


  ## Privates

  def update_statuses(updates)
    [:verified, :expired, :none].each do |status|
      AddressStore.set_verification_status(ids: updates[status], status: status)
    end

    AddressStore.touch(ids: updates[:touch])
  end


  AWS_EXPIRATION_HOURS = 24

  def classify(addr, vaddrs)
    case [addr[:verification_status], vaddrs.include?(addr[:email])]
    when [:verified, true]
      :touch
    when [:verified, false]
      :none
    when [:requested, true]
      :verified
    when [:requested, false]
      if addr[:verification_requested_at] < AWS_EXPIRATION_HOURS.hours.ago
        :expired
      else
        :touch
      end
    when [:none, true]
      :verified
    when [:none, false]
      :touch
    when [:expired, true]
      :verified
    when [:expired, false]
      :touch
    else
      raise ArgumentError.new("Unknown address verification status #{addr}")
    end
  end

  def email_verified?(ses_client, email)
    result = ses_client.get_identity_verification_attributes(emails: [email])
    if result.success
      verification_attributes = result.data
      status = verification_attributes[email]
      if status && status[:verification_status] == 'Success'
        return true
      end
    end
    false
  end
end
