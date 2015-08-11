require_relative '../api'

describe EmailService::API::Addresses do

  let(:emails_api) { EmailService::API::Api }
  let(:now) { Time.zone.local(2015, 8, 7) }

  describe "#get_sender" do
    context "user defined sender address" do

      it "gets sender address by community id" do
        emails_api.addresses.create(
          community_id: 123, address: {
            name: "Email Sender Name",
            email: "hello@mymarketplace.invalid",
            verification_status: :verified
          })

        res = emails_api.addresses.get_sender(community_id: 123)

        expect(res.success).to eq(true)
        expect(res.data).to eq(
                              type: :user_defined,
                              display_format: "Email Sender Name <hello@mymarketplace.invalid>",
                              smtp_format: "\"Email Sender Name\" <hello@mymarketplace.invalid>")
      end

      it "gets the last verified sender address" do
        emails_api.addresses.create(
          community_id: 123, address: {
            name: "Email Sender Name",
            email: "hello@mymarketplace.invalid",
            verification_status: :verified
          })

        Timecop.travel(1.second.from_now) do

          emails_api.addresses.create(
            community_id: 123, address: {
              name: "Email 2 Sender Name",
              email: "hello2@mymarketplace.invalid",
              verification_status: :verified
            })

          res = emails_api.addresses.get_sender(community_id: 123)

          expect(res.success).to eq(true)
          expect(res.data).to eq(
                                type: :user_defined,
                                display_format: "Email 2 Sender Name <hello2@mymarketplace.invalid>",
                                smtp_format: "\"Email 2 Sender Name\" <hello2@mymarketplace.invalid>")
        end

      end

      it "allows nil name" do
        emails_api.addresses.create(
          community_id: 123, address: {
            email: "hello@mymarketplace.invalid",
            verification_status: :verified
          })

        res = emails_api.addresses.get_sender(community_id: 123)

        expect(res.success).to eq(true)
        expect(res.data).to eq(
                              type: :user_defined,
                              display_format: "hello@mymarketplace.invalid",
                              smtp_format: "hello@mymarketplace.invalid")

      end

    end

    context "default sender address" do

      it "returns default address if verified user defined address is not found" do
        emails_api.addresses.create(
          community_id: 123, address: {
            name: "Email Sender Name",
            email: "hello@mymarketplace.invalid",
            verification_status: :requested,
          })

        res = emails_api.addresses.get_sender(community_id: 123)

        expect(res.success).to eq(true)
        expect(res.data).to eq(
                              type: :default,
                              display_format: "Default Sender Name <default_sender@example.com.invalid>",
                              smtp_format: "Default Sender Name <default_sender@example.com.invalid>")
      end

      it "returns default address user defined address is not set" do
        res = emails_api.addresses.get_sender(community_id: 999)

        expect(res.success).to eq(true)
        expect(res.data).to eq(
                              type: :default,
                              display_format: "Default Sender Name <default_sender@example.com.invalid>",
                              smtp_format: "Default Sender Name <default_sender@example.com.invalid>")
      end

      it "returns default address if community id is nil" do
        res = emails_api.addresses.get_sender(community_id: nil)

        expect(res.success).to eq(true)
        expect(res.data).to eq(
                              type: :default,
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
          created = emails_api.addresses.create(
            community_id: 123, address: {
              name: "Email Sender Name",
              email: "hello@mymarketplace.invalid",
              verification_status: :verified
            }).data

          res = emails_api.addresses.get_user_defined(community_id: 123)
          expect(res.success).to eq(true)
          expect(res.data).to eq({
                                   id: created[:id],
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
          emails_api.addresses.create(
            community_id: 123, address: {
              name: "Email Sender Name",
              email: "hello@mymarketplace.invalid",
              verification_status: :verified,
            })
        end

        Timecop.freeze(now + 1.second) do

          created = emails_api.addresses.create(
            community_id: 123, address: {
              name: "Email 2 Sender Name",
              email: "hello2@mymarketplace.invalid",
              verification_status: :verified,
            }).data

          res = emails_api.addresses.get_user_defined(community_id: 123)
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
        res = emails_api.addresses.get_user_defined(community_id: 999)
        expect(res.success).to eq(false)
      end
    end
  end
end
