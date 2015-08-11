module EmailService::SES::Synchronize

  AddressStore = EmailService::Store::Address

  BATCH_SIZE = 1000

  module_function

  def run_batch_synchronization!(ses_client:)
    ses_client.list_verified_addresses.on_success do |vaddrs|
      vaddrs = vaddrs.to_set
      offset = 0
      addresses = AddressStore.load_all(limit: BATCH_SIZE, offset: offset)

      while addresses.present?
        update_statuses(build_sync_updates(addresses, vaddrs))

        offset += BATCH_SIZE
        addresses = AddressStore.load_all(limit: BATCH_SIZE, offset: offset)
      end
    end
  end

  def run_single_synchronization!(community_id:, id:, ses_client:)
    ses_client.list_verified_addresses.on_success { |vaddrs|
      update_statuses(
        build_sync_updates(
          [AddressStore.get(community_id: community_id, id: id)].compact,
          vaddrs))
    }
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
end
