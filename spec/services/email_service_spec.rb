require 'spec_helper'

def email(h)
  defaults = {confirmed_at: Time.now, send_notifications: true}
  HashClass.new(defaults.merge(h))
end

describe EmailService do
  describe "#emails_to_send_message" do

    it "returns all confirmed notification emails" do
      e1 = email(id: 1, send_notifications: false, confirmed_at: Time.now)
      e2 = email(id: 2, send_notifications: true, confirmed_at: Time.now)
      e3 = email(id: 3, send_notifications: true, confirmed_at: Time.now)
      e4 = email(id: 4, send_notifications: true, confirmed_at: nil)

      expect(EmailService.emails_to_send_message([e1, e2, e3, e4])).to eql([e2, e3])
    end

    it "returns first confirmed email if no confirmed notification email is found" do
      e1 = email(id: 1, send_notifications: false, confirmed_at: Time.now)
      e2 = email(id: 2, send_notifications: false, confirmed_at: Time.now)
      e3 = email(id: 3, send_notifications: false, confirmed_at: Time.now)
      e4 = email(id: 4, send_notifications: true, confirmed_at: nil)

      expect(EmailService.emails_to_send_message([e1, e2, e3, e4])).to eql([e1])
    end

    it "otherwise returns an empty array" do
      # This should never happen in production.
      # We should always have at least one confirmed email
      e1 = email(id: 1, send_notifications: false, confirmed_at: nil)
      e2 = email(id: 2, send_notifications: true, confirmed_at: nil)
      e3 = email(id: 3, send_notifications: true, confirmed_at: nil)
      e4 = email(id: 4, send_notifications: true, confirmed_at: nil)

      expect(EmailService.emails_to_send_message([e1, e2, e3, e4])).to eql([])
    end

  end

  describe "#emails_to_smtp_addresses" do

    it "returns comma-separated list of emails" do
      expect(EmailService.emails_to_smtp_addresses([
        email(address: "john.doe@example.com"),
        email(address: "john_d@example.com"),
        email(address: "jdoe@example.com")
      ])).to eql "john.doe@example.com, john_d@example.com, jdoe@example.com"
    end

    it "returns only one email (without commas, of course)" do
      expect(EmailService.emails_to_smtp_addresses([
        email(address: "john.doe@example.com"),
      ])).to eql "john.doe@example.com"
    end

    it "returns empty string" do
      expect(EmailService.emails_to_smtp_addresses([])).to eql ""
    end

  end

  describe "#can_delete_email" do
    it "can not delete email if email count == 1" do
      expect(EmailService.can_delete_email(
        [email(id: 1)],
        email(id: 1),
      )).to eql({result: false, reason: :only_one})

      expect(EmailService.can_delete_email(
        [email(id: 1), email(id: 2)],
        email(id: 1),
      )).to eql({result: true})
    end

    it "can not delete email if that's the only CONFIRMED email" do
      expect(EmailService.can_delete_email(
        [email(id: 1, confirmed_at: Time.now), email(id: 2, confirmed_at: nil)],
        email(id: 1),
      )).to eql({result: false, reason: :only_confirmed})

      expect(EmailService.can_delete_email(
        [email(id: 1, confirmed_at: Time.now), email(id: 2, confirmed_at: Time.now)],
        email(id: 1),
      )).to eql({result: true})
    end

    it "can not delete email if that's the only notification email" do
      expect(EmailService.can_delete_email(
        [email(id: 1, send_notifications: true), email(id: 2, send_notifications: false)],
        email(id: 1),
      )).to eql({result: false, reason: :only_notification})

      expect(EmailService.can_delete_email(
        [email(id: 1, send_notifications: true), email(id: 2, send_notifications: true)],
        email(id: 1),
      )).to eql({result: true})
    end

    it "can not delete email if that's the only CONFIRMED notification email" do
      expect(EmailService.can_delete_email(
        [
          email(id: 1, send_notifications: true, confirmed_at: Time.now),
          email(id: 2, send_notifications: false, confirmed_at: Time.now),
          email(id: 3, send_notifications: true, confirmed_at: nil)
        ],
        email(id: 1),
      )).to eql({result: false, reason: :only_notification})

      expect(EmailService.can_delete_email(
        [
          email(id: 1, send_notifications: true, confirmed_at: Time.now),
          email(id: 2, send_notifications: false, confirmed_at: Time.now),
          email(id: 3, send_notifications: true, confirmed_at: Time.now)
        ],
        email(id: 1),
      )).to eql({result: true})
    end

    it "can not delete email if that's the only email required by community" do
      expect(EmailService.can_delete_email(
        [email(id: 1, address: "john@community.com"), email(id: 2, address: "john@gmail.com")],
        email(id: 1),
        "community.com",
      )).to eql({result: false, reason: :only_allowed})

      expect(EmailService.can_delete_email(
        [email(id: 1, address: "john@community.com"), email(id: 2, address: "john@gmail.com")],
        email(id: 2),
        "community.com",
      )).to eql({result: true})

      # Two allowed emails for one community
      expect(EmailService.can_delete_email(
        [
          email(id: 1, address: "john@community.com"),
          email(id: 2, address: "john@gmail.com"),
          email(id: 3, address: "john@my.community.com")
        ],
        email(id: 1),
        "community.com",
      )).to eql({result: true})

      # Multiple allowed emails for community
      expect(EmailService.can_delete_email(
        [
          email(id: 1, address: "john@community.com"),
          email(id: 2, address: "john@gmail.com"),
          email(id: 3, address: "john@organization.com")
        ],
        email(id: 3),
        "community.com, organization.com",
      )).to eql({result: true})

      # Multiple allowed emails for community, but only one inculed in person
      expect(EmailService.can_delete_email(
        [
          email(id: 1, address: "john@community.com"),
          email(id: 2, address: "john@gmail.com"),
        ],
        email(id: 1),
        "community.com, organization.com",
      )).to eql({result: false, reason: :only_allowed})
    end

    it "can not delete email if that's the only CONFIRMED email required by community" do
      # Two allowed emails for one community
      expect(EmailService.can_delete_email(
        [
          email(id: 1, address: "john@community.com", confirmed_at: nil),
          email(id: 2, address: "john@gmail.com"),
          email(id: 3, address: "john@my.community.com")
        ],
        email(id: 3),
        "community.com",
      )).to eql({result: false, reason: :only_allowed})

            # Two allowed emails for one community
      expect(EmailService.can_delete_email(
        [
          email(id: 1, address: "john@community.com", confirmed_at: Time.now),
          email(id: 2, address: "john@gmail.com"),
          email(id: 3, address: "john@my.community.com", confirmed_at: Time.now)
        ],
        email(id: 1),
        "community.com",
      )).to eql({result: true})
    end
  end
end
