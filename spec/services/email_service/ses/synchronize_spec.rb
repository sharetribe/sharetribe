require 'spec_helper'

Synchronize = EmailService::SES::Synchronize

describe EmailService::SES::Synchronize do

  before(:each) {
    @id = 1
  }

  def next_id
    @id += 1
  end

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

  def store_addresses(addresses)
    addresses.map { |addr|
      m = MarketplaceSenderEmail.new(addr)
      m.id = addr[:id]
      m.save!
      m.reload
    }
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

  describe "#run_batch_synchronization" do
    it "syncs db contents with SES data" do
      now = Time.now()
      Timecop.freeze(now) do

        addresses = (Synchronize::BATCH_SIZE + 10).times.map { gen_address(:new_pending) }
        verified_addresses = emails(addresses[0...Synchronize::BATCH_SIZE / 2])

        original_addresses = store_addresses(addresses)
        orig_updated_at_max = original_addresses.reduce(DateTime.new(0)) { |max, a| a[:updated_at] > max ? a[:updated_at]  : max }

        stubs = {list_verified_email_addresses: {verified_email_addresses: verified_addresses}}
        ses_client = EmailService::SES::Client.new(config: {region: "fake-region", access_key_id: "access_key", secret_access_key: "secret_access_key", sns_topic: "fake-sns-topic-arn"},
                                                   stubs: {list_verified_email_addresses: {verified_email_addresses: verified_addresses}})


        Timecop.travel(now + 5.seconds) do
          Synchronize.run_batch_synchronization!(ses_client: ses_client)

          verified_addresses = MarketplaceSenderEmail.where(verification_status: "verified").pluck(:id)
          pending_addresses = MarketplaceSenderEmail.where(verification_status: "requested").pluck(:id)
          expect(verified_addresses.to_set).to eq(ids(addresses[0...Synchronize::BATCH_SIZE / 2]).to_set)
          expect(pending_addresses.to_set).to eq(ids(addresses[Synchronize::BATCH_SIZE / 2...Synchronize::BATCH_SIZE + 10]).to_set)

          expect(MarketplaceSenderEmail.pluck(:updated_at).all? { |updated_at| updated_at > orig_updated_at_max})
            .to eq(true)
        end
      end
    end
  end

  describe "#run_single_synchronization!" do
    it "syncs single address with SES data" do
      now = Time.now()
      Timecop.freeze(now) do

        addresses = 10.times.map { gen_address(:new_pending) }
        verified_addresses = emails(addresses[0...5])

        store_addresses(addresses)

        stubs = {list_verified_email_addresses: {verified_email_addresses: verified_addresses}}
        ses_client = EmailService::SES::Client.new(config: {region: "fake-region", access_key_id: "access_key", secret_access_key: "secret_access_key", sns_topic: "fake-sns-topic-arn"},
                                                   stubs: {list_verified_email_addresses: {verified_email_addresses: verified_addresses}})


        Timecop.travel(now + 5.seconds) do
          Synchronize.run_single_synchronization!(
            community_id: addresses[0][:community_id],
            id: addresses[0][:id],
            ses_client: ses_client)

          verified_addresses = MarketplaceSenderEmail.where(verification_status: "verified").pluck(:id)
          pending_addresses = MarketplaceSenderEmail.where(verification_status: "requested").pluck(:id)
          expect(verified_addresses.to_set).to eq([addresses[0][:id]].to_set)
          expect(pending_addresses.to_set).to eq(ids(addresses[1...10]).to_set)

          expect(MarketplaceSenderEmail.where(id: addresses[0][:id]).pluck(:updated_at).first > now)
            .to eq(true)
        end
      end
    end
  end

end
