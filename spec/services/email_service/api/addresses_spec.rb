require "spec_helper"

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
        secret_access_key: "secret_access_key",
        sns_topic: "fake-sns-topic-arn"},
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

      it "returns SMTP formatted address, with quotes and special characters properly escaped" do
        # User input: Hello
        # Expected print output: "Hello" <hello@mymarketplace.invalid>
        expect(addresses_wo_ses.create(
          community_id: 1, address: {
            name: "Hello",
            email: "hello@mymarketplace.invalid",
          }).data[:smtp_format]).to eq("\"Hello\" <hello@mymarketplace.invalid>")

        # User input: Hello "Hello" Hello
        # Expected print output: "Hello \"Hello\" Hello" <hello@mymarketplace.invalid>
        expect(addresses_wo_ses.create(
          community_id: 1, address: {
            name: "Hello \"Hello\" Hello",
            email: "hello@mymarketplace.invalid",
          }).data[:smtp_format]).to eq("\"Hello \\\"Hello\\\" Hello\" <hello@mymarketplace.invalid>")

        # User input: Hello \"Hello\" Hello
        # Expected print output: "Hello \\\"Hello\\\" Hello" <hello@mymarketplace.invalid>
        expect(addresses_wo_ses.create(
          community_id: 1, address: {
            name: "Hello \\\"Hello\\\" Hello",
            email: "hello@mymarketplace.invalid",
          }).data[:smtp_format]).to eq("\"Hello \\\\\\\"Hello\\\\\\\" Hello\" <hello@mymarketplace.invalid>")

        # User input: Hello \\"Hello\\" Hello
        # Expected print output: "Hello \\\\\"Hello\\\\\" Hello" <hello@mymarketplace.invalid>
        expect(addresses_wo_ses.create(
          community_id: 1, address: {
            name: "Hello \\\\\"Hello\\\\\" Hello",
            email: "hello@mymarketplace.invalid",
          }).data[:smtp_format]).to eq("\"Hello \\\\\\\\\\\"Hello\\\\\\\\\\\" Hello\" <hello@mymarketplace.invalid>")
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

      it "Lower-cases the email address" do
        created = addresses_wo_ses.create(
          community_id: 123, address: {
            name: "Email 2 Sender Name",
            email: "Hello.World@mymarketplace.invalid"
          }).data

        expect(created[:email]).to eq("hello.world@mymarketplace.invalid")
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

      it "fails for disallowed email providers" do
        res = addresses_with_ses.create(
          community_id: 123, address: {
            name: "Email 2 Sender Name",
            email: "hello2@yahoo.com"
          })

        expect(res.success).to eq(false)
        expect(res.data[:error_code]).to eq(:invalid_domain)
        expect(res.data[:domain]).to eq("yahoo.com")

        res2 = addresses_with_ses.create(
          community_id: 123, address: {
            name: "Email 2 Sender Name",
            email: "hello2@subdomain.yahoo.com"
          })

        expect(res2.success).to eq(false)
        expect(res2.data[:error_code]).to eq(:invalid_domain)
        expect(res2.data[:domain]).to eq("subdomain.yahoo.com")

        res3 = addresses_with_ses.create(
          community_id: 123, address: {
            name: "Email 2 Sender Name",
            email: "hello2@subdomain.yahoo.co.uk"
          })

        expect(res3.success).to eq(false)
        expect(res3.data[:error_code]).to eq(:invalid_domain)
        expect(res3.data[:domain]).to eq("subdomain.yahoo.co.uk")

        res4 = addresses_with_ses.create(
          community_id: 123, address: {
            name: "Email 2 Sender Name",
            email: "hello2@subdomain.yahoo.whatever"
          })

        expect(res4.success).to eq(false)
        expect(res4.data[:error_code]).to eq(:invalid_domain)
        expect(res4.data[:domain]).to eq("subdomain.yahoo.whatever")


        res5 = addresses_with_ses.create(
          community_id: 123, address: {
            name: "Email 2 Sender Name",
            email: "hello2@yahoo.mymarketplace.com"
          })

        # Note: This should fail!
        #
        # However, parsing the host is not that easy, due to the fact
        # that there are top-level domains like co.uk.
        # If this becames a problem, consider adding a gem, e.g.
        # https://github.com/pauldix/domainatrix
        # or https://github.com/weppos/publicsuffix-ruby
        expect(res5.success).to eq(false)
        expect(res5.data[:error_code]).to eq(:invalid_domain)
        expect(res5.data[:domain]).to eq("yahoo.mymarketplace.com")
      end

    end

    it "returns error result if email is malformatted" do
        res_valid = addresses_wo_ses.create(
          community_id: 123, address: {
            name: "Email 2 Sender Name",
            email: "valid_email@example.com"
          })

        expect(res_valid.success).to eq(true)

        res_invalid = addresses_wo_ses.create(
          community_id: 123, address: {
            name: "Email 2 Sender Name",
            email: "invalid_email"
          })

        expect(res_invalid.success).to eq(false)
        expect(res_invalid.error_msg).to eq("Incorrect email format: 'invalid_email'")
        expect(res_invalid.data).to eq(error_code: :invalid_email, email: "invalid_email")
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

  describe "#enqueue_batch_sync" do
    it "enqueues a batch sync" do
      SyncDelayedJobObserver.enable!
      Timecop.freeze(now) do

        addresses_with_ses.create(
          community_id: 123, address: {
            name: "Email 2 Sender Name",
            email: "hello2@mymarketplace.invalid"
          })
        addresses_with_ses.create(
          community_id: 321, address: {
            name: "Email 3 Sender Name",
            email: "hello3@mymarketplace.invalid"
          })

        Timecop.travel(now + 3.seconds) do
          addresses_with_ses.enqueue_batch_sync()

          addresses = [addresses_with_ses.get_user_defined(community_id: 123).data,
                       addresses_with_ses.get_user_defined(community_id: 321).data]

          addresses.each do |address|
            expect(address[:updated_at]).to eq(now + 3.seconds)
          end
        end
      end
    end

    it "does nothing when no ses client defined" do
      SyncDelayedJobObserver.enable!
      Timecop.freeze(now) do

        addresses_wo_ses.create(
          community_id: 123, address: {
            name: "Email 2 Sender Name",
            email: "hello2@mymarketplace.invalid"
          })
        addresses_wo_ses.create(
          community_id: 321, address: {
            name: "Email 3 Sender Name",
            email: "hello3@mymarketplace.invalid"
          })

        Timecop.travel(now + 3.seconds) do
          addresses_wo_ses.enqueue_batch_sync()

          addresses = [addresses_wo_ses.get_user_defined(community_id: 123).data,
                       addresses_wo_ses.get_user_defined(community_id: 321).data]

          addresses.each do |address|
            expect(address[:updated_at]).to eq(now)
          end
        end
      end

    end
  end
end
