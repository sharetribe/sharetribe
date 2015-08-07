module EmailService::SES::Synchronize

  module_function

  def build_sync_updates(addresses, verified_addresses)
    vaddrs = verified_addresses.to_set
    updates = { verified: [], expired: [], touch: [], none: [] }

    addresses.each do |a|
      updates[classify(a, vaddrs)].push(a[:id])
    end

    updates
  end


  ## Privates

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
