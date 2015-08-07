require 'spec_helper'

Synchronize = EmailService::SES::Synchronize

@id = 0
def next_id
  @id += 1
end

describe EmailService::SES::Synchronize do

  def get_type(type)
    {
      old_pending: -> () { [:requested, (25 + rand(24)).hours.ago]},
      new_pending: -> () { [:requested, rand(24).hours.ago]},
      verified: -> () { [:verified, nil]},
      none: -> () { [:none, nil]}
    }[type]
  end

  def gen_str(len)
    len.times.map { ('a'..'z').to_a[rand(26)] }.join("")
  end

  def gen_email
    "#{gen_str(20)}@#{gen_str(10)}.#{gen_str(3)}}"
  end

  def gen_address(type)
    status, verification_requested_at = get_type(type).call()

    { id: next_id(),
      community_id: 1,
      name: gen_str(25),
      email: gen_email(),
      verification_status: status,
      verification_requested_at: verification_requested_at }
  end

  def ids(addresses)
    addresses.map { |a| a[:id] }
  end

  def emails(addresses)
    addresses.map { |a| a[:email] }
  end

  describe "#build_sync_updates" do
    it "marks verified requested as verified" do
      addresses = 10.times.map { gen_address(:new_pending) }
      verified_addresses = emails(addresses[0...5])

      expect(Synchronize.build_sync_updates(addresses, verified_addresses))
        .to eq({verified: ids(addresses[0...5]),
                expired: [],
                touch: ids(addresses[5...10]),
                none: []})
    end

    it "marks old pending requested as expired" do
      addresses = 10.times.map { gen_address(:old_pending) }
      verified_addresses = emails(addresses[5...10])

      expect(Synchronize.build_sync_updates(addresses, verified_addresses))
        .to eq({verified: ids(addresses[5...10]),
                expired: ids(addresses[0...5]),
                touch: [],
                none: []})

    end

    it "marks non-verified verified as none" do
      addresses = 10.times.map { gen_address(:verified) }
      verified_addresses = emails(addresses[5...10])

      expect(Synchronize.build_sync_updates(addresses, verified_addresses))
        .to eq({touch: ids(addresses[5...10]),
                none: ids(addresses[0...5]),
                verified: [],
                expired: []})

    end

  end
end
