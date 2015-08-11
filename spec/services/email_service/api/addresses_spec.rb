require_relative "api.rb"

describe EmailService::API::Addresses do

  AddressStore = EmailService::Store::Address

  let(:addresses_wo_ses) do
    EmailService::API::Addresses.new(
      default_sender: "Default Sender Name <default_sender@example.com.invalid>",
      ses_client: nil)
  end

  let(:ses_client) do
    EmailService::SES::Client.new(
      config: {
        region: "fake-region",
        access_key_id: "access_key",
        secret_access_key: "secret_access_key"},
      stubs: true)
  end

  let(:addresses_with_ses) do
    EmailService::API::Addresses.new(
      default_sender: "Default Sender Name <default_sender@example.com.invalid>",
      ses_client: ses_client)
  end

  let(:now) { Time.zone.local(2015, 8, 7) }

  before(:each) do
    SyncDelayedJobObserver.reset!
  end

  after(:each) do
    SyncDelayedJobObserver.reset!
  end

  describe "#get_sender" do
    context "user defined sender address" do

      it "gets sender address by community id" do
        addresses_wo_ses.create(
          community_id: 123, address: {
            name: "Email Sender Name",
            email: "hello@mymarketplace.invalid",
          })

        res = addresses_wo_ses.get_sender(community_id: 123)

        expect(res.success).to eq(true)
        expect(res.data).to eq(
                              type: :user_defined,
                              display_format: "Email Sender Name <hello@mymarketplace.invalid>",
                              smtp_format: "\"Email Sender Name\" <hello@mymarketplace.invalid>")
      end

      it "gets the last verified sender address" do
        addresses_wo_ses.create(
          community_id: 123, address: {
            name: "Email Sender Name",
            email: "hello@mymarketplace.invalid",
          })

        Timecop.travel(1.second.from_now) do

          addresses_wo_ses.create(
            community_id: 123, address: {
              name: "Email 2 Sender Name",
              email: "hello2@mymarketplace.invalid",
            })

          res = addresses_wo_ses.get_sender(community_id: 123)

          expect(res.success).to eq(true)
          expect(res.data).to eq(
                                type: :user_defined,
                                display_format: "Email 2 Sender Name <hello2@mymarketplace.invalid>",
                                smtp_format: "\"Email 2 Sender Name\" <hello2@mymarketplace.invalid>")
        end

      end

      it "allows nil name" do
        addresses_wo_ses.create(
          community_id: 123, address: {
            email: "hello@mymarketplace.invalid",
          })

        res = addresses_wo_ses.get_sender(community_id: 123)

        expect(res.success).to eq(true)
        expect(res.data).to eq(
                              type: :user_defined,
                              display_format: "hello@mymarketplace.invalid",
                              smtp_format: "hello@mymarketplace.invalid")

      end

    end

    context "default sender address" do

      it "returns default address user defined address is not set" do
        res = addresses_wo_ses.get_sender(community_id: 999)

        expect(res.success).to eq(true)
        expect(res.data)
          .to eq(type: :default,
                 display_format: "Default Sender Name <default_sender@example.com.invalid>",
                 smtp_format: "Default Sender Name <default_sender@example.com.invalid>")
      end

      it "returns default address if community id is nil" do
        res = addresses_wo_ses.get_sender(community_id: nil)

        expect(res.success).to eq(true)
        expect(res.data)
          .to eq(type: :default,
                 display_format: "Default Sender Name <default_sender@example.com.invalid>",
                 smtp_format: "Default Sender Name <default_sender@example.com.invalid>")
      end

      it "returns default address when user defined not yet verified" do
        SyncDelayedJobObserver.enable!

        created = addresses_with_ses.create(
          community_id: 123, address: {
            name: "Email 2 Sender Name",
            email: "hello2@mymarketplace.invalid"
          })

        res = addresses_with_ses.get_sender(community_id: 123)

        expect(res.success).to eq(true)
        expect(res.data)
          .to eq(type: :default,
                 display_format: "Default Sender Name <default_sender@example.com.invalid>",
                 smtp_format: "Default Sender Name <default_sender@example.com.invalid>")
      end
    end
  end

  describe "#get_user_defined" do

    context "success" do
      it "returns unique user defined address by community id and email" do
        now = Time.zone.local(2015, 8, 10)
        Timecop.freeze(now) do
          created = addresses_wo_ses.create(
            community_id: 123, address: {
              name: "Email Sender Name",
              email: "hello@mymarketplace.invalid",
            }).data

          res = addresses_wo_ses.get_user_defined(community_id: 123)
          expect(res.success).to eq(true)
          expect(res.data)
            .to eq({id: created[:id],
                    community_id: 123,
                    name: "Email Sender Name",
                    email: "hello@mymarketplace.invalid",
                    updated_at: created[:updated_at],
                    verification_status: :verified,
                    verification_requested_at: nil,
                    display_format: "Email Sender Name <hello@mymarketplace.invalid>",
                    smtp_format: "\"Email Sender Name\" <hello@mymarketplace.invalid>"})
        end
      end

      it "returns always the latest email" do
        now = Time.zone.local(2015, 8, 10)
        Timecop.freeze(now) do
          addresses_wo_ses.create(
            community_id: 123, address: {
              name: "Email Sender Name",
              email: "hello@mymarketplace.invalid",
            })
        end

        Timecop.freeze(now + 1.second) do

          created = addresses_wo_ses.create(
            community_id: 123, address: {
              name: "Email 2 Sender Name",
              email: "hello2@mymarketplace.invalid",
            }).data

          res = addresses_wo_ses.get_user_defined(community_id: 123)
          expect(res.success).to eq(true)
          expect(res.data).to eq({
                                   id: created[:id],
                                   community_id: 123,
                                   name: "Email 2 Sender Name",
                                   email: "hello2@mymarketplace.invalid",
                                   verification_status: :verified,
                                   verification_requested_at: nil,
                                   updated_at: created[:updated_at],
                                   display_format: "Email 2 Sender Name <hello2@mymarketplace.invalid>",
                                   smtp_format: "\"Email 2 Sender Name\" <hello2@mymarketplace.invalid>"})
        end
      end
    end

    context "error" do
      it "returns error if none found" do
        res = addresses_wo_ses.get_user_defined(community_id: 999)
        expect(res.success).to eq(false)
      end
    end
  end

  describe "#create" do
    context "no ses client configured" do
      it "Creates addresses in :verified status" do
        created = addresses_wo_ses.create(
          community_id: 123, address: {
            name: "Email 2 Sender Name",
            email: "hello2@mymarketplace.invalid"
          }).data

        expect(created[:verification_status]).to eq(:verified)
      end
    end

    context "ses client configured" do

      it "Creates addresses in :none status" do
        created = addresses_with_ses.create(
          community_id: 123, address: {
            name: "Email 2 Sender Name",
            email: "hello2@mymarketplace.invalid"
          }).data

        expect(created[:verification_status]).to eq(:none)
      end

      it "enqueues a verification request" do
        SyncDelayedJobObserver.enable!
        Timecop.freeze(now) do

          addresses_with_ses.create(
            community_id: 123, address: {
              name: "Email 2 Sender Name",
              email: "hello2@mymarketplace.invalid"
            })

          address = addresses_with_ses.get_user_defined(community_id: 123).data
          expect(address[:verification_status]).to eq(:requested)
          expect(address[:verification_requested_at]).to eq(now)
        end

      end

    end
  end

  describe "#enqueue_status_sync" do
    it "enqueues a status sync for the given address" do
      SyncDelayedJobObserver.enable!
      Timecop.freeze(now) do

        created = addresses_with_ses.create(
          community_id: 123, address: {
            name: "Email 2 Sender Name",
            email: "hello2@mymarketplace.invalid"
          }).data

        Timecop.travel(now + 2.seconds) do
          addresses_with_ses.enqueue_status_sync(
            community_id: created[:community_id],
            id: created[:id])

          address = addresses_with_ses.get_user_defined(community_id: created[:community_id]).data
          expect(address[:updated_at]).to eq(now + 2.seconds)
        end
      end
    end

    it "does nothing if no ses client defined" do
      SyncDelayedJobObserver.enable!
      Timecop.freeze(now) do

        created = addresses_wo_ses.create(
          community_id: 123, address: {
            name: "Email 2 Sender Name",
            email: "hello2@mymarketplace.invalid"
          }).data

        Timecop.travel(now + 2.seconds) do
          addresses_wo_ses.enqueue_status_sync(
            community_id: created[:community_id],
            id: created[:id])

          address = addresses_wo_ses.get_user_defined(community_id: created[:community_id]).data
          expect(address[:updated_at]).to eq(now)
        end
      end
    end
  end

  describe "#enqueue verification request" do
    it "enqueues a fresh verification request for the given address" do
      SyncDelayedJobObserver.enable!
      Timecop.freeze(now) do

        created = addresses_with_ses.create(
          community_id: 123, address: {
            name: "Email 2 Sender Name",
            email: "hello2@mymarketplace.invalid"
          }).data

        Timecop.travel(now + 4.seconds) do
          addresses_with_ses.enqueue_verification_request(
            community_id: created[:community_id],
            id: created[:id])

          address = addresses_with_ses.get_user_defined(community_id: created[:community_id]).data
          expect(address[:verification_requested_at]).to eq(now + 4.seconds)
        end
      end
    end

    it "does nothing when no ses client defined" do
      SyncDelayedJobObserver.enable!
      Timecop.freeze(now) do

        created = addresses_wo_ses.create(
          community_id: 123, address: {
            name: "Email 2 Sender Name",
            email: "hello2@mymarketplace.invalid"
          }).data

        Timecop.travel(now + 4.seconds) do
          addresses_wo_ses.enqueue_verification_request(
            community_id: created[:community_id],
            id: created[:id])

          address = addresses_wo_ses.get_user_defined(community_id: created[:community_id]).data
          expect(address[:verification_requested_at]).to eq(nil)
        end
      end
    end
  end
end
